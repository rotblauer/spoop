require 'helpers'
require 'spoop_constants'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :lockable, :timeoutable, :validatable

  # attr_encrypted :donor_id, key: Rails.application.secrets.secret_key_base, if: :donor?
  attr_encrypted :admin_secret, key: Rails.application.secrets.secret_key_base, if: :admin?

  ROLES = ['donor', 'admin', 'public']
  GROUPS = ['open_biome', 'site', 'public']

  # TODO: destroy, really? 
	has_many :open_biome_logs, dependent: :destroy
	has_many :donor_logs, dependent: :destroy
	has_many :meta_logs, dependent: :destroy 
	has_many :visits
	has_one :api_key, dependent: :destroy
	

	validates :email, presence: true
	validates :email, uniqueness: true
	# validates_format_of :email, with: Devise.email_regexp, if: :email_changed?, allow_blank: false #with: Devise.email_regexp,
	validates_format_of :email, with: SpoopConstants::VALID_EMAIL_REGEX, if: :email_changed?, allow_blank: false #with: Devise.email_regexp,
	
	validates :read_the_fine_print, inclusion: {in: [true]}
	
	validates :role, presence: true
	validates :role, inclusion: { in: ROLES }

	validates :group, inclusion: { in: GROUPS }
	
	validates :donor_id, presence: true, if: :donor?
	validates :donor_id, uniqueness: true, if: :donor?
	VALID_DONOR_NUMBERS = ENV['valid_donor_numbers'].split(',').map{ |a| a.to_i }  
	validates :donor_id, :inclusion => { :in => VALID_DONOR_NUMBERS }, if: :donor?
	
	
	ADMIN_SECRETS = [].append(ENV['admin_secret'])
	validate :knows_admin_secret_if_admin, on: :create

	before_create :set_default_values
	# before_create :set_admin_number, if: :admin?
	after_create :create_user_api_key
	after_update :sync_api_key_role, if: :role_changed?


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
  # def set_admin_number
  # 	last_admin_number = User.admins.maximum(:donor_id)
  # 	self.donor_id = last_admin_number.to_i + 1
  # end

  # encrypt the admin secret before writing.
  # def admin_secret=(adminsecret)
  # 	write_attribute(:admin_secret, Helpers.encryptify(adminsecret))
  # end

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

  def create_user_api_key
		ApiKey.find_or_create_by!(user_id: id, role: role)
  end

	def sync_api_key_role
		ApiKey.find_by(user_id: id).update_column(:role, role) 
	end

	private

	def knows_admin_secret_if_admin
		unless donor?
			unless ADMIN_SECRETS.include?(self.admin_secret)
				errors.add(:admin_secret, 'is wrong')
			end
		end
	end

	protected

end