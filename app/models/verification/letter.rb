class Verification::Letter
  include ActiveModel::Model

  attr_accessor :user, :address, :verification_code

  validates :user, presence: true
  validates :address, presence: true
  validate :correct_address

  def save
    valid? &&
    letter_requested! &&
    update_user_address
  end

  def address
    @address ||= CensusApi.new(user).address
  end

  def letter_requested!
    user.update(letter_requested_at: Time.now, letter_verification_code: generate_verification_code)
  end

  def verify?
    validate_letter_sent
    validate_correct_code
    errors.blank?
  end

  def validate_letter_sent
    errors.add(:verification_code, I18n.t('verification.letter.errors.letter_not_sent')) unless
    user.letter_sent_at.present?
  end

  def validate_correct_code
    errors.add(:verification_code, I18n.t('verification.letter.errors.incorect_code')) unless
    user.letter_verification_code == verification_code
  end

  def correct_address
    errors.add(:address, I18n.t('verification.letter.errors.address_not_found')) unless
    address.present?
  end

  def update_user_address
    user.address = Address.new(parsed_address)
    user.save
  end

  def parsed_address
    { postal_code:   address[:codigo_postal],
      street:        address[:nombre_via],
      street_type:   address[:sigla_via],
      number:        address[:numero_via],
      number_type:   address[:nominal_via],
      letter:        address[:letra_via],
      portal:        address[:portal],
      stairway:      address[:escalera],
      floor:         address[:planta],
      door:          address[:puerta],
      km:            address[:km],
      neighbourhood: address[:nombre_barrio],
      district:      address[:nombre_distrito] }
  end

  def increase_letter_verification_tries
    user.update(letter_verification_tries: user.letter_verification_tries += 1)
  end

  private

    def generate_verification_code
      rand.to_s[2..7]
    end

end
