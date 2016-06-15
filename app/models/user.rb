require 'helpers'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  # attr_encrypted :email, key: Rails.application.secrets.secret_key_base, attribute: 'email'

  ROLES = ['donor', 'admin', 'open']
  GROUPS = ['open_biome', 'site', 'open']

  # TODO: dependent, really?
	has_many :open_biome_logs, dependent: :destroy
	has_many :donor_logs, dependent: :destroy
	has_many :meta_logs, dependent: :destroy 
	has_many :visits
	has_one :api_key, dependent: :destroy
	

	#email is a real email
	validates_format_of :email, :with => SpoopConstants::VALID_EMAIL_REGEX
	validates :email, presence: true
	validates :email, uniqueness: true
	
	#make sure they claim to read the fine print
	validates :read_the_fine_print, inclusion: {in: [true]}
	
	validates :role, presence: true
	validates :role, inclusion: { in: ROLES }

	validates :group, inclusion: { in: GROUPS }
	
	#grab and check against secret donor numbers
	VALID_DONOR_NUMBERS = ENV['valid_donor_numbers'].split(',').map{|a|a.to_i}
	validates :donor_id, :inclusion => { :in => VALID_DONOR_NUMBERS }, if: :donor? 
	#unique donor number
	validates :donor_id, uniqueness: true, if: :donor?
	
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

end