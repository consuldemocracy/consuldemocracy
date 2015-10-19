class Verification::Letter
  include ActiveModel::Model

  attr_accessor :user, :verification_code, :email, :password, :verify

  validates :user, presence: true

  validate :letter_sent, if: :verify?
  validate :correct_code, if: :verify?

  def save
    valid? &&
    letter_requested!
  end

  def letter_requested!
    user.update(letter_requested_at: Time.now, letter_verification_code: generate_verification_code)
  end

  def letter_sent
    errors.add(:verification_code, I18n.t('verification.letter.errors.letter_not_sent')) unless
    user.letter_sent_at.present?
  end

  def correct_code
    errors.add(:verification_code, I18n.t('verification.letter.errors.incorect_code')) unless
    user.letter_verification_code == verification_code
  end

  def verify?
    verify.present?
  end

  def increase_letter_verification_tries
    user.update(letter_verification_tries: user.letter_verification_tries += 1)
  end

  private

    def generate_verification_code
      rand.to_s[2..7]
    end

end
