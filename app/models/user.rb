require 'helpers'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :lockable, :timeoutable #, :validatable

  attr_encrypted :email, key: Rails.application.secrets.secret_key_base
  
  
  def email_required?
    true
  end

  def email_changed?
    encrypted_email_changed? #self.
  end 

  # def self.find_for_authentication(tainted_conditions)
  #   # User.find_by_donor_id(tainted_conditions[:donor_id])
  #   User.find_by_email(tainted_conditions[:email])
  #   # User.find_by_donor_id()
  #   # User.find_by_email(tainted_conditions[:email])
  # end

  # def self.find_for_database_authentication(warden_conditions)
  #   conditions = warden_conditions.dup
  #   if donor_id = conditions.delete(:donor_id)
  #     where(conditions.to_h).where(["donor_id = :value", { :value => donor_id.to_i }]).first
  #   elsif conditions.has_key?(:donor_id)
  #     where(conditions.to_h).first
  #   end
  # end

  # def self.find_first_by_auth_conditions(tainted_conditions, opts={})
  # 	User.find_by_email(tainted_conditions[:email])
  # end

  def password_required?
  	true
  end

  # def email_was
		# User.decrypt_email(encrypted_email_was)
  # end

  # def apply_to_attribute_or_variable(attr, method)

  # end

  # def email_unique?
  #   records = Array(self.class.find_by(email: self.email))
  #   records.reject{|u| self.persisted? && u.id == self.id}.empty?
  # end
  

  ROLES = ['donor', 'admin', 'open']
  GROUPS = ['open_biome', 'site', 'open']

  # TODO: dependent, really?
	has_many :open_biome_logs, dependent: :destroy
	has_many :donor_logs, dependent: :destroy
	has_many :meta_logs, dependent: :destroy 
	has_many :visits
	has_one :api_key, dependent: :destroy
	

	#email is a real email
	# MIGRATE TO DONOR_ID CENTRIC
	# validates_format_of :email, :with => SpoopConstants::VALID_EMAIL_REGEX
	# validates :email, presence: true
	# validates :email, uniqueness: true
	# 
	# validate :validate_email_uniqueness #validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
	validates :email, presence: true
	validates_format_of :email, with: Devise.email_regexp, if: :email_changed?, allow_blank: false #with: Devise.email_regexp,
	
	validates :read_the_fine_print, inclusion: {in: [true]}
	
	validates :role, presence: true
	validates :role, inclusion: { in: ROLES }

	validates :group, inclusion: { in: GROUPS }
	
	VALID_DONOR_NUMBERS = ENV['valid_donor_numbers'].split(',').map{ |a| a }  
	validates :donor_id, :inclusion => { :in => VALID_DONOR_NUMBERS }, if: :donor? 
	validates :donor_id, presence: true
	validates :donor_id, uniqueness: true
	
	ADMIN_SECRETS = [].append(ENV['admin_secret'])
	validate :knows_admin_secret_if_admin, on: :create


	before_create :set_default_values
	after_create :create_user_api_key
	after_save :sync_api_key_role, if: :role_changed?


	scope :donors, -> { where(role: 'donor') }
	scope :admins, -> { where(role: 'admin') }
	scope :open, -> { where(role: 'open') } #flushers
	scope :no_robots, -> { where(demo: false) }
	scope :g_open_biome, -> { where(group: 'open_biome') }
	scope :g_site, -> { where(group: 'site') }
	scope :g_open, -> { where(group: 'open') }

  def set_default_values
    self.role ||= 'donor'
    self.group ||= 'open_biome'
    self.donor_logs_are_private_by_default ||= true
  end

  # encrypt the admin secret before writing.
  def admin_secret=(adminsecret)
  	write_attribute(:admin_secret, Helpers.encryptify(adminsecret))
  end

  def create_user_api_key
		self.create_api_key(role: self.role) if self.api_key.nil?
  end

  ## FIXME: should be suffixed with '?' --> admin?
	def admin?
		role == 'admin'
	end
	def donor?
		role == 'donor'
	end
	def site_admin?
		role == 'admin' && group == 'site'
	end

	# strict identity check
	def is_user(user)
		self == user
	end

	private

	def sync_api_key_role
		create_user_api_key
		self.api_key.update_column(:role, self.role) 
	end

	def knows_admin_secret_if_admin
		unless donor?
			# decrypt before checking against env var
			unless ADMIN_SECRETS.include?(Helpers.decryptify(admin_secret))
				errors.add(:admin_secret, 'is wrong')
			end
		end
	end

	protected

	# def validate_email_uniqueness
	#   errors.add(:email, :taken) unless email_unique?
	# end

end