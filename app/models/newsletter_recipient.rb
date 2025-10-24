class NewsletterRecipient < ApplicationRecord
  attribute :token, default: -> { SecureRandom.hex(16) }
  attribute :active, default: -> { !Setting["feature.gdpr.require_consent_for_notifications"] }

  scope :by_email, ->(search_email) { where("email ILIKE ?", "%#{search_email.strip}%") }
  scope :active, -> { where(active: true).where.not(confirmed_at: nil) }
  scope :inactive, -> { where.not(active: true) }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :user_check

  def user_check
    return unless User.where.not(confirmed_at: nil).find_by(email: email)

    errors.add(:email, I18n.t("errors.messages.taken"))
  end

  def editable_by?(user)
    user.confirmed? && user.email == email
  end
end
