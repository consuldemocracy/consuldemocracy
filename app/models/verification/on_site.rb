class Verification::OnSite
  include ActiveModel::Model

  attr_accessor :document_type
  attr_accessor :document_number
  attr_accessor :email
  attr_accessor :should_validate_email

  validates :document_type, :document_number, presence: true
  validate :validate_email, if: :should_validate_email

  def user
    @user ||=
      User.where(email: email).first ||
      User.by_document(document_type, document_number).first
  end

  def user?
    user.present?
  end

  def in_census?
    CensusApi.new.call(document_type, document_number).valid?
  end

  def verified?
    user? && user.level_three_verified?
  end

  def verify
    user.update(verified_at: Time.now) if user?
  end

  def send_verification_email
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



