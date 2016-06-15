require 'helpers'
require 'spoop_constants'
require 'hashtag_parser'

class DonorLog < ActiveRecord::Base
  
  belongs_to :user
  has_many :meta_logs
  has_many :open_biome_logs, through: :meta_logs

  before_save :set_default_values
  #helper attr setup for grouping by date
  before_save :date_of_passage_depends_on_time_of_passage

  after_create :parse_tags_from_notes
  # after_create Helpers.establish_meta_log(self, SpoopConstants::LOG_MATCH_MINUTES_WINDOW)
  after_save :establish_meta_log
  def establish_meta_log
    match = OpenBiomeLog.where(donor_number: self.donor_number).where('time_of_passage > ?', self.time_of_passage - SpoopConstants::LOG_MATCH_MINUTES_WINDOW).where('time_of_passage < ?', self.time_of_passage + SpoopConstants::LOG_MATCH_MINUTES_WINDOW)
    m = MetaLog.find_or_initialize_by(user_id: user_id, donor_log_id: id)
    if match.any?
      m.open_biome_log_id = match.first.id
    end
    m.save
  end

  before_destroy :update_and_maybe_remove_meta_log
  def update_and_maybe_remove_meta_log
    m = MetaLog.find_by(user_id: self.user_id, donor_log_id: self.id)
    if m.open_biome_log_id
      m.donor_log_id = nil
      m.save
    else
      m.destroy
    end
  end
  
  after_update :parse_tags_from_notes

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
    self.tag_list.add(self.notes, parser: HashtagParser) # this IS persisting the new tag. idk why. 
  end

  def time_of_passage_is_less_than_or_equal_to_about_now
    errors.add(:time_of_passage, 'can\'t be (too far) in the future.') if time_of_passage > Time.zone.now + 10.minutes
  end

  def belongs_to_donor
    flash[:danger] = 'You must be an Open Biome donor to deal in donor logs.' && errors.add(:user_id, 'isn\'t an Open Biome donor.') unless self.user.role == 'donor'
  end

end
