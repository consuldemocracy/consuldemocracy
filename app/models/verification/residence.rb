class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  validates_presence_of :document_number
  validates_presence_of :document_type
  validates_presence_of :date_of_birth
  validates_presence_of :postal_code
  validates :terms_of_service, acceptance: { allow_nil: false }

  validates :postal_code, length: { is: 5 }

  validate :residence_in_madrid
  validate :document_number_uniqueness

  def initialize(attrs={})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    self.document_number.upcase! unless self.document_number.blank?
  end

  def save
    return false unless valid?
    user.update(document_number:       document_number,
                document_type:         document_type,
                residence_verified_at: Time.now)
  end

  def document_number_uniqueness
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.where(document_number: document_number).any?
  end

  def residence_in_madrid
    return if errors.any?
    self.date_of_birth = date_to_string(date_of_birth)

    residency = CensusApi.new(self)

    unless residency.valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
    self.date_of_birth = string_to_date(date_of_birth)
  end

  def store_failed_attempt
    FailedCensusCall.create({
      user: user,
      document_number: document_number,
      document_type:   document_type,
      date_of_birth:   date_of_birth,
      postal_code:     postal_code
    })
  end

end
