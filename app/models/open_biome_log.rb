require 'csv'
require 'roo'
require 'time'
require 'helpers'
require 'spoop_constants'

class OpenBiomeLog < ActiveRecord::Base
  
  belongs_to :user
  has_many :meta_logs, dependent: :nullify
  has_many :donor_logs, through: :meta_logs

  # Damn it Eduardo, changing up the attributes. 
  alias_attribute :processing_result, :processing_state

  scope :processed, -> {
      where(processing_state: 'processed')}
  scope :no_robots, -> { where.not(donor_number: User.where(demo: true).map{|u| u.donor_id }) }

  validate :donor_number_matches_donor
  def donor_number_matches_donor
    unless donor_number == User.find(self.user_id).donor_id.to_i
      errors.add(:donor_number, 'does not match donor.')
    end
  end

  validates :processing_state, presence: true

  # # after_create Helpers.establish_meta_log(self, SpoopConstants::LOG_MATCH_MINUTES_WINDOW)
  # after_save :establish_meta_log
  # def establish_meta_log
  #   match = DonorLog.where(donor_number: self.donor_number).where('time_of_passage > ?', self.time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW).where('time_of_passage < ?', self.time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW).first

  #   if match.present?
  #     m = MetaLog.find_by(user_id: user_id, donor_log_id: match.id)
  #     m.update_attributes(open_biome_log_id: id) 
  #   else 
  #     MetaLog.create!(user_id: user_id, open_biome_log_id: id)
  #   end
  # end
  

  # Create. 
  # - look for meta_log in time frame
  # - add self id to meta_log or create meta_log
  # Update.
  # - if time_of_passage_changed?
  # - if > 10.minutes diff from existing meta_log
  # - - create new meta_log
  # - - remove self.id from old meta_log
  # - if < 10.minutes diff from existing meta_log
  # - - do nothing
  # 
  # 
  # 
  after_create :find_and_update_or_initialize_meta_log
  after_update :find_and_update_or_initialize_meta_log_on_change, if: :time_of_passage_changed?
  def find_and_update_or_initialize_meta_log
    meta = meta_log_by_time
    if meta.present?
      #FIXME this assumes that poops are unique to within the time frame -- ie if you have two poops within 20 minutes of each other, they'll disappear (not deleted, but 'opposite-orphaned')
      meta.update_attributes(open_biome_log_id: id) 
    else 
      meta_logs.create(time_of_passage: time_of_passage)
    end
  end
  def find_and_update_or_initialize_meta_log_on_change
    unless meta_log_is_within_time_frame?
      own_meta_log.update_attributes(open_biome_log_id: nil)
      find_and_update_or_initialize_meta_log
    end
  end

  ## extended meta helpers
  #TODO implement for DonorLog
  def own_meta_log
    meta_logs.first
  end
  def meta_log_by_time(time_of_passage=self.time_of_passage)
    window = SpoopConstants::LOG_MATCH_MINUTES_WINDOW
    time_frame_start = time_of_passage - window
    time_frame_latest = time_of_passage + window
    MetaLog.where('time_of_passage > ? AND time_of_passage < ?', time_frame_start, time_frame_latest).first #is only one. better be
  end
  def meta_log_is_within_time_frame?
    own_meta_log == meta_log_by_time
  end
  
  #de-orphan metalogs
  after_destroy :update_and_maybe_remove_meta_log
  def update_and_maybe_remove_meta_log
    MetaLog.orphans.each(&:destroy)
  end

  def processable
    processing_state == 'processed' ? true : false
  end
  def donated
    true
  end

  #could do moar validations, but idk bout how dey roll 
  # validates :donated_on, presence: true
  # validates :weight, presence: true
  # validates :sample, presence: true


  # Import from csv.
  # should return an array of hashes [{new record},{new record}]
  def self.import(file, user)
 
    time_columns = ['time_of_passage', 'time_received', 'time_started', 'time_finished']
    return_array = []


    case File.extname(file.original_filename)
    when ".csv"

      csv = CSV.read(file.path, :headers => true)

      csv.each do |row|

        # Will hold tidied versions of keys and values. 
        hashy = {}
        row.to_hash.each do |key, value|
        
          k = Helpers.attributize(key)
          v = Helpers.to_something(value) unless (time_columns.include?(k) || k == 'donated_on')
          v = Helpers.parse_date_from_backwards_string(value) if k == 'donated_on'
          v = value.to_s if time_columns.include?(k)

          if v.class == String
            v.squish!
          end

          hashy[k] = v
        end

        time_columns.each do |d|
          base_date = hashy['donated_on']
          military_time = hashy[d] # string?!
          if military_time.present? && military_time.length > 3
            m = military_time.split(':')
            hh = m[0].to_i
            mm = m[1].to_i
            dd = base_date + hh.hours + mm.minutes 
            df = Helpers.fix_tzs(dd)
            hashy[d] = df
          else 
            hashy[d] = nil 
          end
        end
        hashy[:user_id] = user.id
        return_array.append(hashy)
      end

      return return_array

    when ".xls" then spreadsheet = Roo::Excel.new(file.path)#nil, :ignore
    when ".xlsx" then spreadsheet = Roo::Excelx.new(file.path)#nil, :ignore
    else raise "Unknown file type: #{file.original_filename}"
    end

    header = spreadsheet.row(1).map{ |h| Helpers.attributize(h) }

    (2..spreadsheet.last_row).each do |i|
      
      # Will hold tidied versions of keys and values. 
      hashy = {}

      row = Hash[[header, spreadsheet.row(i)].transpose]
      row.each do |k, v|
        
        v = Helpers.to_something(v) unless (time_columns.include?(k) || k == 'donated_on')
        
        puts v if k == 'donated_on'
        v = Time.zone.at(v.in_time_zone('UTC').beginning_of_day) if k == 'donated_on'
        puts v if k == 'donated_on'
        v = v.to_i if time_columns.include?(k)
        if v.class == String
          v.squish!
        end
        hashy[k] = v
      end

      time_columns.each do |time_column|
        base_date = hashy['donated_on']

        # experiment with roo time detection
        break if hashy[time_column].nil?
        int = hashy[time_column]
        puts int
        hour_min_hash = Helpers.make_a_time_from_a_strange_number(int)
        puts hour_min_hash.inspect
        t = base_date + hour_min_hash[:hours].hours + hour_min_hash[:minutes].minutes
        puts "---> #{t}"
        hashy[time_column] = t#Time.at(t).in_time_zone('UTC')
        puts "----> #{hashy[time_column]}"
      end
      hashy[:user_id] = user.id
      return_array.append(hashy)
    end
    return return_array
  end

  # TODO: add params
  # {'123123124124': 1, '123434234234':1, ...}
  def self.heatmap_data(conditional, condition)
    data_obj = {}
    OpenBiomeLog.where(conditional, condition).each {|obl| data_obj[obl.time_of_passage.to_i] = 1}
    data_obj.to_json
  end



  
end
