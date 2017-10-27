# REQUIREMENT TOL-2: Redefine Census verification model to use custom Toledo's service
class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks

  before_validation :retrieve_toledo_census_data

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, length: { is: 5 }
  validate :postal_code_in_toledo
  validate :residence_in_toledo

  validate :allowed_age
  validate :document_number_uniqueness

  def initialize(attrs = {})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    clean_document_number
  end

  def save
    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number:       document_number,
                document_type:         document_type,
                geozone:               geozone,
                date_of_birth:         date_of_birth.to_datetime,
                gender:                gender,
                residence_verified_at: Time.current)
  end

  def allowed_age
    return if errors[:date_of_birth].any? || Age.in_years(date_of_birth) >= User.minimum_required_age
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age'))
  end

  def document_number_uniqueness
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.active.where(document_number: document_number).any?
  end

  def store_failed_attempt
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      date_of_birth: date_of_birth,
      postal_code: postal_code
    )
  end

  def geozone
    Geozone.where(census_code: district_code).first
  end

  def district_code
    @census_data.district_code
  end

  def gender
    @census_data.gender
  end

  def clean_document_number
    self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
  end

  def postal_code_in_toledo
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_toledo
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_toledo, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

  def residency_valid?
    @census_data.valid? &&
      @census_data.postal_code == postal_code &&
      @census_data.date_of_birth == date_of_birth
  end

  def valid_postal_code?
    postal_code =~ /^450/
  end

  def retrieve_toledo_census_data
    # REQUIREMENT TOL-2: Check citizen in census using custom Census Caller
    @census_data = ToledoCensusCaller.new.call(document_type, document_number)
  end
end
