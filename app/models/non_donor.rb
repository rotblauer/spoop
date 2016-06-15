class NonDonor < ActiveRecord::Base
	
	validates :email, presence: true
	validates :email, uniqueness: true 
	# http://apidock.com/rails/ActiveModel/Validations/ClassMethods/validates_format_of
	validates_format_of :email, :with => SpoopConstants::VALID_EMAIL_REGEX

end
