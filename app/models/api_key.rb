class ApiKey < ActiveRecord::Base
  belongs_to :user
  before_create :generate_access_token
  before_create :set_expiration

  def expired?
    DateTime.now >= self.expires_at
 	end

  private 

	  def generate_access_token
	  	begin 
	  		# https://github.com/genericsteele/token_phrase
	  		self.access_token = TokenPhrase.generate(:numbers => false) # SecureRandom.hex
	  	end while self.class.exists?(access_token: access_token)
	  end

	  def set_expiration
	    self.expires_at = DateTime.now.in_time_zone + 3.years # TODO: halflife
	 	end

end
