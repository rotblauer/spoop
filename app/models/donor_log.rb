require 'helpers'
require 'spoop_constants'
require 'hashtag_parser'

class DonorLog < ActiveRecord::Base
  
  belongs_to :user
  has_many :meta_logs, dependent: :nullify
  has_many :open_biome_logs, through: :meta_logs

  before_save :set_default_values
  #helper attr setup for grouping by date
  before_save :date_of_passage_depends_on_time_of_passage

  after_create :parse_tags_from_notes
  after_update :parse_tags_from_notes
  
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
  after_create :find_and_update_or_initialize_meta_log
  after_update :find_and_update_or_initialize_meta_log_on_change, if: :time_of_passage_changed?
  def find_and_update_or_initialize_meta_log
    meta = MetaLog.where('time_of_passage > ?', time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW).where('time_of_passage < ?', time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW).first #only is one
    if meta.present?
      #IMPROVE this assumes that poops are unique to within the time frame -- ie if you have two poops within 20 minutes of each other, they'll disappear (not deleted, but 'opposite-orphaned')
      meta.update_attributes(donor_log_id: id) 
    else 
      meta_logs.create(time_of_passage: time_of_passage)
    end
  end
  def find_and_update_or_initialize_meta_log_on_change
    meta = self.meta_logs.first
    #FIXME -- so that if a user adjusts dl time by 4 minutes that change is visible in the logs index
    #if meta ISN'T still within time frame
    unless meta.time_of_passage < time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW || meta.time_of_passage > time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW
      # remove self from old meta_log
      meta.donor_log_id = nil
      # same as on create
      find_and_update_or_initialize_meta_log
    end
  end
  # after_save :establish_meta_log
  # def establish_meta_log
    # if !meta_logs.any? || 
    #   match = OpenBiomeLog.where(donor_number: self.donor_number).where('time_of_passage > ?', self.time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW).where('time_of_passage < ?', self.time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW).first
    #   if match.present?
    #     m = MetaLog.find_by(user_id: user_id, open_biome_log_id: match.id)
    #     m.update_attributes(donor_log_id: id) 
    #   else 
    #     MetaLog.create!(user_id: user_id, donor_log_id: id)
    #   end
  #   end
  # end

  after_destroy :update_and_maybe_remove_meta_log
  def update_and_maybe_remove_meta_log
    MetaLog.orphans.each(&:destroy)
  end
  
  

  acts_as_taggable # Alias for acts_as_taggable_on :tags

  #handling scopes
  scope :shared, -> { where(is_private: false) }
  scope :processed, -> { where(processable: true) }
  scope :rejected, -> { where('processable IS ? AND donated IS ?', false, true)}
  scope :not_donated, -> { where(donated: false) }
  scope :no_robots, -> { where.not(user_id: User.where(demo: true).map{|u| u.id }) }

  # times
  scope :last_three_months, -> {
      where( 'time_of_passage > ? AND time_of_passage < ?', 
              3.month.ago, 
              Time.zone.now )}
  scope :last_two_months, -> {
      where( 'time_of_passage > ? AND time_of_passage < ?', 
              2.month.ago, 
              Time.zone.now )}
  scope :this_month, -> {
  	where('time_of_passage > ? AND time_of_passage < ?', 
  		1.month.ago,
  		Time.zone.now)
  }
  scope :this_week, -> {
  	where('time_of_passage > ? AND time_of_passage < ?', 
  		1.week.ago,
  		Time.zone.now)
  }
  scope :today, -> {
  	where("time_of_passage >= ?", Time.zone.now.beginning_of_day)
  }


  validates :weight, presence: true
  validates :weight, numericality: true
  validates :bristol_score, presence: true
  validates :bristol_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 7 }

  validate :time_of_passage_is_less_than_or_equal_to_about_now
  validate :belongs_to_donor
  validate :must_be_donated_to_be_processable

  def set_default_values
    self.donor_number ||= self.user.donor_id
  end

  def date_of_passage_depends_on_time_of_passage
    self.date_of_passage = Helpers.get_date_of_passage(self.time_of_passage)
  end
  
  def outcome_in_words
    if processable
      return 'processable'
    elsif !processable && donated
      return 'rejected'
    else 
      return 'not_donated'
    end
  end

  def parse_tags_from_notes
    # notes = self.notes #=> 'I ate a #cucumber and went for a #run today.'
    self.tag_list = '' # clear out the tag list
    self.tag_list.add(notes, parser: HashtagParser) # this IS persisting the new tag. idk why. 
  end

  def time_of_passage_is_less_than_or_equal_to_about_now
    errors.add(:time_of_passage, 'can\'t be (too far) in the future.') if time_of_passage > Time.zone.now + SpoopConstants::LOG_MATCH_MINUTES_WINDOW
  end

  def belongs_to_donor
    # flash[:danger] = 'You must be an Open Biome donor to deal in donor logs.' &&
    errors.add(:user_id, 'isn\'t an Open Biome donor.') unless user.role == 'donor'
  end

  def must_be_donated_to_be_processable
    if processable
      errors.add(:processable, 'must be true.') unless donated
    end
  end

end
