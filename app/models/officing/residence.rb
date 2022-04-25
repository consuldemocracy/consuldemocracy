class Officing::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :officer, :document_number, :document_type, :postal_code

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  validates :document_type, presence: true

  validate :successful_census_request
  validate :user_is_citizen?
  validate :valid_age?

  def initialize(attrs = {})
    super
    clean_document_number
  end

  def save
    return false unless valid? && @census_api_response.valid?

    if user_exists?
      self.user = find_user_by_document
      user.update!(verified_at: Time.current)
    else
      user_params = {
        document_number:       document_number,
        document_type:         document_type,
        geozone:               geozone,
        residence_verified_at: Time.current,
        verified_at:           Time.current,
        erased_at:             Time.current,
        password:              random_password,
        terms_of_service:      "1",
        email:                 nil
      }
      self.user = User.create!(user_params)
    end
  end

  def save!
    validate! && save
  end

  def store_failed_census_call
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      postal_code: postal_code,
      poll_officer: officer
    )
  end

  def user_exists?
    find_user_by_document.present?
  end

  def find_user_by_document
    User.find_by(document_number: document_number, document_type: document_type)
  end

  def local_residence
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:local_residence, false)
    end
  end

  def geozone
    Geozone.find_by(census_code: district_code)
  end

  def district_code
   @census_api_response.geozone_external_code
  end

  def response_date_of_birth
    @census_api_response.date_of_birth
  end

  private

    def retrieve_census_data
      @census_api_response = CustomCensusApi.new.call(document_type, document_number, postal_code)
    end

    def residency_valid?
      @census_api_response.valid? && valid_age? && @census_api_response.is_citizen?
    end

    def valid_age?
      return unless Rails.env.production? || Rails.env.staging?

      return if errors.any?

      unless @census_api_response.census_age >= 16
        errors.add(:date_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
      end
    end

    def successful_census_request
      return if errors.include?(:document_number)

      unless @census_api_response.valid?
        errors.add(:document_number, "Ha habido un error al consultar el censo")
      end
    end

    def user_is_citizen?
      return true unless Rails.env.production? || Rails.env.staging?

      return if errors.any?

      unless @census_api_response.is_citizen?
        errors.add(:document_number, "Este usuario no está empadronado")
      end
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

    def random_password
      (0...20).map { ("a".."z").to_a[rand(26)] }.join
    end
end
