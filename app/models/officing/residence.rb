class Officing::Residence
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :officer, :document_number, :document_type, :year_of_birth

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :year_of_birth, presence: true

  validate :allowed_age
  validate :residence_in_madrid

  def initialize(attrs = {})
    super
    clean_document_number
  end

  def save
    return false unless valid?

    if user_exists?
      self.user = find_user_by_document
      user.update(verified_at: Time.current)
    else
      user_params = {
        document_number:       document_number,
        document_type:         document_type,
        geozone:               geozone,
        date_of_birth:         date_of_birth.in_time_zone.to_datetime,
        gender:                gender,
        residence_verified_at: Time.current,
        verified_at:           Time.current,
        erased_at:             Time.current,
        password:              random_password,
        terms_of_service:      '1',
        email:                 nil
      }
      self.user = User.create!(user_params)
    end
  end

  def store_failed_census_call
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      year_of_birth: year_of_birth,
      poll_officer: officer
    )
  end

  def user_exists?
    find_user_by_document.present?
  end

  def find_user_by_document
    User.where(document_number: document_number,
               document_type:   document_type).first
  end

  def residence_in_madrid
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:residence_in_madrid, false)
    end
  end

  def allowed_age
    return if errors[:year_of_birth].any?
    return unless @census_api_response.valid?

    unless allowed_age?
      errors.add(:year_of_birth, I18n.t('verification.residence.new.error_not_allowed_age'))
    end
  end

  def allowed_age?
    Age.in_years(date_of_birth) >= User.minimum_required_age
  end

  def geozone
    Geozone.where(census_code: district_code).first
  end

  def district_code
    @census_api_response.district_code
  end

  def gender
    @census_api_response.gender
  end

  def date_of_birth
    @census_api_response.date_of_birth
  end

  private

    def retrieve_census_data
      @census_api_response = CensusCaller.new.call(Tenant.find_by(subdomain: Apartment::Tenant.current),document_type, document_number)
    end

    def residency_valid?
      @census_api_response.valid? &&
        @census_api_response.date_of_birth.year.to_s == year_of_birth.to_s
    end

    def census_year_of_birth
      @census_api_response.date_of_birth.year
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

    def random_password
      (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    end

end
