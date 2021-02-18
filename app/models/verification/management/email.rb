class Verification::Management::Email
  include ActiveModel::Model

  attr_accessor :document_type, :document_number, :email

  validates :document_type, :document_number, :email, presence: true
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validate :validate_user
  validate :validate_document_number

  delegate :username, to: :user, allow_nil: true

  def user
    @user ||= User.find_by(email: email)
  end

  def user?
    user.present?
  end

  def save
    return false unless valid?

    plain_token, encrypted_token = Devise.token_generator.generate(User, :email_verification_token)

    user.update!(document_type: document_type,
                 document_number: document_number,
                 residence_verified_at: Time.current,
                 level_two_verified_at: Time.current,
                 email_verification_token: plain_token)

    Mailer.email_verification(user, email, encrypted_token, document_type, document_number).deliver_later
    true
  end

  def save!
    validate! && save
  end

  private

    def validate_user
      return if errors.count > 0

      if !user?
        errors.add(:email, I18n.t("errors.messages.user_not_found"))
      elsif user.level_three_verified?
        errors.add(:email, I18n.t("management.email_verifications.already_verified"))
      end
    end

    def validate_document_number
      return if errors.count > 0

      if document_number_mismatch?
        errors.add(:email,
                   I18n.t("management.email_verifications.document_mismatch",
                           document_type: ApplicationController.helpers.humanize_document_type(user.document_type),
                           document_number: user.document_number))
      end
    end

    def document_number_mismatch?
      user? && user.document_number.present? &&
        (user.document_number != document_number || user.document_type != document_type)
    end
end
