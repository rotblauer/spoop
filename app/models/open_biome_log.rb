require 'csv'
require 'time'
require 'helpers'
require 'spoop_constants'

class OpenBiomeLog < ActiveRecord::Base
  
  belongs_to :user
  has_many :meta_logs
  has_many :donor_logs, through: :meta_logs

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

  # after_create Helpers.establish_meta_log(self, SpoopConstants::LOG_MATCH_MINUTES_WINDOW)
  after_save :establish_meta_log
  def establish_meta_log
    match = DonorLog.where(donor_number: self.donor_number).where('time_of_passage > ?', self.time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW).where('time_of_passage < ?', self.time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW)
    m = MetaLog.find_or_initialize_by(user_id: user_id, open_biome_log_id: id)
    if match.any?
      m.donor_log_id = match.first.id
    end
    m.save
  end
  before_destroy :update_and_maybe_remove_meta_log
  def update_and_maybe_remove_meta_log
    m = MetaLog.find_by(user_id: self.user_id, open_biome_log_id: self.id)
    if m.donor_log_id
      m.open_biome_log_id = nil
      m.save
    else
      m.destroy
    end
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
 
    return_array = []

    csv = CSV.read(file.path, :headers => true)

    csv.each do |row|

      # Will hold tidied versions of keys and values. 
      hashy = {}
      danger_fruit = ['time_of_passage', 'time_received', 'time_started', 'time_finished']

      row.to_hash.each do |key, value|
      
        k = Helpers.attributize(key)
        v = Helpers.to_something(value) unless (danger_fruit.include?(k) || k == 'donated_on')
        v = Helpers.parse_date_from_backwards_string(value) if k == 'donated_on'
        v = value.to_s if danger_fruit.include?(k)

        if v.class == String
          v.squish!
        end

        hashy[k] = v
      end

      danger_fruit.each do |d|
        base_date = hashy['donated_on']
        # puts "base_date -> #{base_date}"
        military_time = hashy[d] # string?!
        if !(military_time.length < 3)
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
  end

  # TODO: add params
  # {'123123124124': 1, '123434234234':1, ...}
  def self.heatmap_data(conditional, condition)
    data_obj = {}
    OpenBiomeLog.where(conditional, condition).each {|obl| data_obj[obl.time_of_passage.to_i] = 1}
    data_obj.to_json
  end



  
end
