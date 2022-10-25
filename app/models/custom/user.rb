class User < ApplicationRecord
  include Verification

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, :password_expirable, :secure_validatable,
         authentication_keys: [:login]

  acts_as_voter
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  include Graphqlable

  has_one :administrator
  has_one :moderator
  has_one :valuator
  has_one :manager
  has_one :poll_officer, class_name: "Poll::Officer"
  has_one :organization
  has_one :lock
  has_many :flags
  has_many :identities, dependent: :destroy
  has_many :debates, -> { with_hidden }, foreign_key: :author_id
  has_many :proposals, -> { with_hidden }, foreign_key: :author_id
  has_many :budget_investments, -> { with_hidden }, foreign_key: :author_id, class_name: 'Budget::Investment'
  has_many :comments, -> { with_hidden }
  has_many :spending_proposals, foreign_key: :author_id
  has_many :failed_census_calls
  has_many :notifications
  has_many :direct_messages_sent,     class_name: 'DirectMessage', foreign_key: :sender_id
  has_many :direct_messages_received, class_name: 'DirectMessage', foreign_key: :receiver_id
  has_many :legislation_answers, class_name: 'Legislation::Answer', dependent: :destroy, inverse_of: :user
  has_many :follows
  belongs_to :geozone

  validates :username, presence: true, if: :username_required?
  validates :username, uniqueness: { scope: :registering_with_oauth }, if: :username_required?

  #validates :email, uniqueness: true
  validates_uniqueness_of :email, allow_nil: true, allow_blank: true

  validates :document_number, uniqueness: { scope: :document_type }, allow_nil: true

  validates :phone_number, presence: true, length: { is: 9 },
                           numericality: true,
                           format: { with: /(6|7|9)[0-9]+/,
                                     message: I18n.t('users.registrations.phone_validation') },
                           on: :create

  validate :validate_username_length

  validates :official_level, inclusion: {in: 0..5}
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validates_associated :organization, message: false

  accepts_nested_attributes_for :organization, update_only: true

  attr_accessor :skip_password_validation
  attr_accessor :use_redeemable_code
  attr_accessor :login

  scope :administrators, -> { joins(:administrator) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }
  scope :officials,      -> { where("official_level > 0") }
  scope :newsletter,     -> { where(newsletter: true) }
  scope :for_render,     -> { includes(:organization) }
  scope :by_document,    ->(document_type, document_number) do
    where(document_type: document_type, document_number: document_number)
  end
  scope :email_digest,   -> { where(email_digest: true) }
  scope :active,         -> { where(erased_at: nil) }
  scope :erased,         -> { where.not(erased_at: nil) }
  scope :public_for_api, -> { all }
  scope :by_comments,    ->(query, topics_ids) { joins(:comments).where(query, topics_ids).uniq }
  scope :by_authors,     ->(author_ids) { where("users.id IN (?)", author_ids) }
  scope :by_username_email_or_document_number, ->(search_string) do
    string = "%#{search_string}%"
    where("username ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", string, string, string)
  end

  before_validation :clean_document_number

  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_email_confirmed = oauth_email.present? && (auth.info.verified || auth.info.verified_email)
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_user || User.new(
      username:  auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: '1',
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil
    )
  end

  def name
    organization? ? organization.name : username
  end

  def debate_votes(debates)
    voted = votes.for_debates(Array(debates).map(&:id))
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def proposal_votes(proposals)
    voted = votes.for_proposals(Array(proposals).map(&:id))
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def legislation_proposal_votes(proposals)
    voted = votes.for_legislation_proposals(proposals)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def spending_proposal_votes(spending_proposals)
    voted = votes.for_spending_proposals(spending_proposals)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def budget_investment_votes(budget_investments)
    voted = votes.for_budget_investments(budget_investments)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def comment_flags(comments)
    comment_flags = flags.for_comments(comments)
    comment_flags.each_with_object({}){ |f, h| h[f.flaggable_id] = true }
  end

  def voted_in_group?(group)
    votes.for_budget_investments(Budget::Investment.where(group: group)).exists?
  end

  def administrator?
    administrator.present?
  end

  def moderator?
    moderator.present?
  end

  def valuator?
    valuator.present?
  end

  def manager?
    manager.present?
  end

  def poll_officer?
    poll_officer.present?
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

  def has_official_email?
    domain = Setting['email_domain_for_officials']
    email.present? && ((email.end_with? "@#{domain}") || (email.end_with? ".#{domain}"))
  end

  def display_official_position_badge?
    return true if official_level > 1
    official_position_badge? && official_level == 1
  end

  def block
    debates_ids = Debate.where(author_id: id).pluck(:id)
    comments_ids = Comment.where(user_id: id).pluck(:id)
    proposal_ids = Proposal.where(author_id: id).pluck(:id)
    investment_ids = Budget::Investment.where(author_id: id).pluck(:id)
    proposal_notification_ids = ProposalNotification.where(author_id: id).pluck(:id)

    hide

    Debate.hide_all debates_ids
    Comment.hide_all comments_ids
    Proposal.hide_all proposal_ids
    Budget::Investment.hide_all investment_ids
    ProposalNotification.hide_all proposal_notification_ids
  end

  def erase(erase_reason = nil)
    update(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil#,
      #document_number: (self.document_number || 'nodn') + Time.now.strftime("%Y%m%d%H%M%S")
    )
    identities.destroy_all
  end

  def erased?
    erased_at.present?
  end

  def take_votes_if_erased_document(document_number, document_type)
    erased_user = User.erased.where(document_number: document_number)
                             .where(document_type: document_type).first
    if erased_user.present?
      take_votes_from(erased_user)
      erased_user.update(document_number: nil, document_type: nil)
    end
  end

  def take_votes_from(other_user)
    return if other_user.blank?
    Poll::Voter.where(user_id: other_user.id).update_all(user_id: id)
    Budget::Ballot.where(user_id: other_user.id).update_all(user_id: id)
    Vote.where("voter_id = ? AND voter_type = ?", other_user.id, "User").update_all(voter_id: id)
    data_log = "id: #{other_user.id} - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    update(former_users_data_log: "#{former_users_data_log} | #{data_log}")
  end

  def locked?
    Lock.find_or_create_by(user: self).locked?
  end

  def self.search(term)
    term.present? ? where("email = ? OR username ILIKE ?", term, "%#{term}%") : none
  end

  def self.username_max_length
    @@username_max_length ||= columns.find { |c| c.name == 'username' }.limit || 60
  end

  def self.minimum_required_age
    (Setting['min_age_to_participate'] || 16).to_i
  end

  def show_welcome_screen?
    verification = Setting["feature.user.skip_verification"].present? ? true : unverified?
    sign_in_count == 1 && verification && !organization && !administrator?
  end

  def password_required?
    return false if skip_password_validation
    super
  end

  def username_required?
    !organization? && !erased?
  end

  def email_required?
    !erased? && unverified?
  end

  def locale
    self[:locale] ||= I18n.default_locale.to_s
  end

  def confirmation_required?
    super && !registering_with_oauth
  end

  def send_oauth_confirmation_instructions
    if oauth_email != email
      update(confirmed_at: nil)
      send_confirmation_instructions
    end
    update(oauth_email: nil) if oauth_email.present?
  end

  def name_and_email
    "#{name} (#{email})"
  end

  def age
    Age.in_years(date_of_birth)
  end

  def save_requiring_finish_signup
    begin
      self.registering_with_oauth = true
      save(validate: false)
    # Devise puts unique constraints for the email the db, so we must detect & handle that
    rescue ActiveRecord::RecordNotUnique
      self.email = nil
      save(validate: false)
    end
    true
  end

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def timeout_in
    30.minutes
  end

  def public_proposals
    public_activity? ? proposals : User.none
  end

  def public_debates
    public_activity? ? debates : User.none
  end

  def public_comments
    public_activity? ? comments : User.none
  end

  # overwritting of Devise method to allow login using email OR username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_hash).where(["lower(email) = ?", login.downcase]).first ||
    where(conditions.to_hash).where(["username = ?", login]).first
  end

  def self.find_by_manager_login(manager_login)
    find_by(id: manager_login.split("_").last)
  end

  def interests
    followables = follows.map(&:followable)
    followables.compact.map { |followable| followable.tags.map(&:name) }.flatten.compact.uniq
  end

  def self.desempadronados
    where.not(residence_verified_at: nil).each do |u|



    end
  end

  def can_create_investments(budget)
    budget_headings = budget.groups.first&.headings&.pluck(:id)
    user_headings = budget.investments.where(author_id: id).pluck(:heading_id)

    budget_headings != user_headings
  end

  def self.old_version(document_number)
    with_hidden.where(document_number: document_number, email: nil).first
  end

  def move(document_number)
    return false unless document_number.present?

    old_user = User.with_hidden.where(document_number: document_number).first
    Activity.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Administrator.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Ahoy::Event.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Annotation.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Budget::Ballot.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Budget::Investment.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Budget::Investment.where(administrator_id: old_user.id).each do |resource|
      resource.administrator_id = id
      resource.save
    end
    Budget::ReclassifiedVote.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Budget::ValuatorAssignment.where(valuator_id: old_user.id).each do |resource|
      resource.valuator_id = id
      resource.save
    end
    Comment.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Comment.where(moderator_id: old_user.id).each do |resource|
      resource.moderator_id = id
      resource.save
    end
    Comment.where(administrator_id: old_user.id).each do |resource|
      resource.administator_id = id
      resource.save
    end
    Debate.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    DirectMessage.where(sender_id: old_user.id).each do |resource|
      resource.sender_id = id
      resource.save
    end
    DirectMessage.where(receiver_id: old_user.id).each do |resource|
      resource.receiver_id = id
      resource.save
    end
    Document.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    FailedCensusCall.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Flag.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Follow.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Identity.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Image.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Legislation::Annotation.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Legislation::Answer.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Legislation::Proposal.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Legislation::Question.where(author_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Lock.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Manager.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Moderator.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Notification.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Organization.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Poll::Answer.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Poll::OfficerAssignment.where(officer_id: old_user.id).each do |resource|
      resource.officer_id = id
      resource.save
    end
    Poll::Officer.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Poll::PartialResult.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Poll::Question.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Poll::Recount.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Poll::Shift.where(officer_id: old_user.id).each do |resource|
      resource.officer_id = id
      resource.save
    end
    Poll::Voter.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.origin ||= 'web'
      resource.save
    end
    Poll.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    ProposalNotification.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    Proposal.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    RelatedContentScore.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    RelatedContent.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    SignatureSheet.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    SpendingProposal.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    SpendingProposal.where(administrator_id: old_user.id).each do |resource|
      resource.administrator_id = id
      resource.save
    end
    Topic.where(author_id: old_user.id).each do |resource|
      resource.author_id = id
      resource.save
    end
    ValuationAssignment.where(valuator_id: old_user.id).each do |resource|
      resource.valuator_id = id
      resource.save
    end
    Valuator.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Visit.where(user_id: old_user.id).each do |resource|
      resource.user_id = id
      resource.save
    end
    Vote.where(voter_id: old_user.id).each do |resource|
      resource.voter_id = id
      resource.save
    end
  end

  private

    def clean_document_number
      return unless document_number.present?
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase
    end

    def validate_username_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :username,
        maximum: User.username_max_length)
      validator.validate(self)
    end

end

# == Schema Information
#
# Table name: users
#
#  id                             :integer          not null, primary key
#  email                          :string           default("")
#  encrypted_password             :string           default(""), not null
#  reset_password_token           :string
#  reset_password_sent_at         :datetime
#  remember_created_at            :datetime
#  sign_in_count                  :integer          default(0), not null
#  current_sign_in_at             :datetime
#  last_sign_in_at                :datetime
#  current_sign_in_ip             :string
#  last_sign_in_ip                :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  confirmation_token             :string
#  confirmed_at                   :datetime
#  confirmation_sent_at           :datetime
#  unconfirmed_email              :string
#  email_on_comment               :boolean          default(FALSE)
#  email_on_comment_reply         :boolean          default(FALSE)
#  phone_number                   :string(30)
#  official_position              :string
#  official_level                 :integer          default(0)
#  hidden_at                      :datetime
#  sms_confirmation_code          :string
#  username                       :string(60)
#  document_number                :string
#  document_type                  :string
#  residence_verified_at          :datetime
#  email_verification_token       :string
#  verified_at                    :datetime
#  unconfirmed_phone              :string
#  confirmed_phone                :string
#  letter_requested_at            :datetime
#  confirmed_hide_at              :datetime
#  letter_verification_code       :string
#  failed_census_calls_count      :integer          default(0)
#  level_two_verified_at          :datetime
#  erase_reason                   :string
#  erased_at                      :datetime
#  public_activity                :boolean          default(TRUE)
#  newsletter                     :boolean          default(TRUE)
#  notifications_count            :integer          default(0)
#  registering_with_oauth         :boolean          default(FALSE)
#  locale                         :string
#  oauth_email                    :string
#  geozone_id                     :integer
#  redeemable_code                :string
#  gender                         :string(10)
#  date_of_birth                  :datetime
#  email_on_proposal_notification :boolean          default(TRUE)
#  email_digest                   :boolean          default(TRUE)
#  email_on_direct_message        :boolean          default(TRUE)
#  official_position_badge        :boolean          default(FALSE)
#  password_changed_at            :datetime         default(Thu, 01 Jan 2015 02:01:01 CET +01:00), not null
#  created_from_signature         :boolean          default(FALSE)
#  failed_email_digests_count     :integer          default(0)
#  former_users_data_log          :text             default("")
#  public_interests               :boolean          default(FALSE)
#
