class Verification::Management::Email
  include ActiveModel::Model

  attr_accessor :document_type
  attr_accessor :document_number
  attr_accessor :email

  validates :document_type, :document_number, :email, presence: true
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validate :validate_user

  def user
    @user ||= User.where(email: email).first
  end

  def user?
    user.present?
  end

  def save
    return false unless valid?

    plain_token, encrypted_token = Devise.token_generator.generate(User, :email_verification_token)
    user.update(email_verification_token: plain_token)
    Mailer.email_verification(user, email, encrypted_token).deliver_later
    true
  end

  def already_verified?
    user? && user.level_three_verified?
  end

  def document_number_mismatch?
    user? && user.document_number.present? &&
      (user.document_number != document_number || user.document_type != document_type)
  end

  def validate_user
    return if errors.count > 0
    errors.add(:email, I18n.t('errors.messages.user_not_found')) unless user?
    if already_verified?
      errors.add(:email, I18n.t('management.users.already_verified'))
    elsif document_number_mismatch?
      errors.add(:email,
                 I18n.t('management.users.document_mismatch',
                         document_type: ApplicationController.helpers.humanize_document_type(user.document_type),
                         document_number: user.document_number))
    end
  end
end
