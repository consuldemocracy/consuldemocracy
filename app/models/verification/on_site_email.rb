class Verification::OnSiteEmail
  include ActiveModel::Model

  attr_accessor :document_type
  attr_accessor :document_number
  attr_accessor :email

  validates :document_type, :document_number, presence: true
  validate :validate_email

  def user
    @user ||= User.where(email: email).first
  end

  def user?
    user.present?
  end

  def send_email
    # FIXME
    # Should assign document_number here?
    # Should send verification email here?
  end

  def validate_email
    if email.blank?
      errors.add(:email, I18n.t('errors.messages.blank'))
    elsif email !~ Devise.email_regexp
      errors.add(:email, I18n.t('errors.messages.invalid'))
    elsif !user?
      errors.add(:email, I18n.t('errors.messages.user_not_found')) unless user?
    end
  end
end
