class Verification::Letter
  include ActiveModel::Model

  attr_accessor :user, :verification_code, :email, :password, :verify

  validate :validate_existing_user

  validates :email, presence: true, if: :verify?
  validates :password, presence: true, if: :verify?
  validates :verification_code, presence: true, if: :verify?

  validate :validate_correct_code, if: :verify?

  def save
    valid? &&
    letter_requested!
  end

  def letter_requested!
    user.update(letter_requested_at: Time.current, letter_verification_code: generate_verification_code)
  end

  def validate_existing_user
    unless user
      errors.add(:email, I18n.t('devise.failure.invalid', authentication_keys: 'email'))
    end
  end

  def validate_correct_code
    return if errors.include?(:verification_code)
    if user.try(:letter_verification_code).to_i != verification_code.to_i
      errors.add(:verification_code, I18n.t('verification.letter.errors.incorrect_code'))
    end
  end

  def verify?
    verify.present?
  end

  def increase_letter_verification_tries
    user.update(letter_verification_tries: user.letter_verification_tries += 1)
  end

  private

    # six-digit numbers, zero not the first digit
    def generate_verification_code
      rand(100000..999999).to_s
    end

end
