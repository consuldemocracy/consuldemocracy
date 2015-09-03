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
    user.update(letter_requested_at: Time.now, letter_verification_code: four_digit_code)
  end

  def verify?
    user.letter_verification_code == verification_code
  end

  def update_user_address
    user.address = Address.new(parsed_address)
    user.save
  end

  def correct_address
    errors.add(:address, "Address not found") unless address.present?
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

  def four_digit_code
    rand.to_s[2..5]
  end

end
