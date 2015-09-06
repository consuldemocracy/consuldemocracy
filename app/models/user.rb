class User < ActiveRecord::Base
  include Verification

  OMNIAUTH_EMAIL_PREFIX = 'omniauth@participacion'
  OMNIAUTH_EMAIL_REGEX  = /\A#{OMNIAUTH_EMAIL_PREFIX}/

  apply_simple_captcha
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :async

  acts_as_voter
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_one :address
  has_one :administrator
  has_one :moderator
  has_one :organization
  has_many :flags
  has_many :identities, dependent: :destroy
  has_many :debates, -> { with_hidden }, foreign_key: :author_id
  has_many :comments, -> { with_hidden }

  validates :username, presence: true, unless: :organization?
  validates :username, uniqueness: true, unless: :organization?
  validates :official_level, inclusion: {in: 0..5}
  validates_format_of :email, without: OMNIAUTH_EMAIL_REGEX, on: :update
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validates_associated :organization, message: false

  accepts_nested_attributes_for :organization

  scope :administrators, -> { joins(:administrators) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }
  scope :officials,      -> { where("official_level > 0") }
  scope :for_render,     -> { includes(:organization) }

  def self.find_for_oauth(auth, signed_in_resource = nil)
    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user
    user ||= first_or_create_for_oauth(auth)

    # Associate the identity with the user if needed
    identity.update_user(user)
    user
  end

  # Get the existing user by email if the provider gives us a verified email.
  # If no verified email was provided we assign a temporary email and ask the
  # user to verify it on the next step via RegistrationsController.finish_signup
  def self.first_or_create_for_oauth(auth)
    email = auth.info.email if auth.info.verified || auth.info.verified_email
    user  = User.where(email: email).first if email

    # Create the user if it's a new registration
    if user.nil?
      user = User.new(
        username: auth.info.nickname || auth.extra.raw_info.name.parameterize('-') || auth.uid,
        email: email ? email : "#{OMNIAUTH_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end

    user
  end

  def name
    organization? ? organization.name : username
  end

  def debate_votes(debates)
    voted = votes.for_debates(debates)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def comment_flags(comments)
    comment_flags = flags.for_comments(comments)
    comment_flags.each_with_object({}){ |f, h| h[f.flaggable_id] = true }
  end

  def administrator?
    administrator.present?
  end

  def moderator?
    moderator.present?
  end

  def organization?
    organization.present?
  end

  def verified_organization?
    organization && organization.verified?
  end

  def official?
    official_level && official_level > 0
  end

  def add_official_position!(position, level)
    return if position.blank? || level.blank?
    update official_position: position, official_level: level.to_i
  end

  def remove_official_position!
    update official_position: nil, official_level: 0
  end

  def self.search(term)
    term.present? ? where("email = ? OR username ILIKE ?", term, "%#{term}%") : none
  end

  def email_provided?
    !!(email && email !~ OMNIAUTH_EMAIL_REGEX) ||
      !!(unconfirmed_email && unconfirmed_email !~ OMNIAUTH_EMAIL_REGEX)
  end

end
