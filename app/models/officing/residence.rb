class Officing::Residence
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Attributes::Normalization
  include ActiveModel::Validations::Callbacks
  include HasDocumentNumberAndDocumentType

  attribute :date_of_birth, :date
  attr_accessor :user, :officer, :year_of_birth, :postal_code

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting.force_presence_date_of_birth? }
  validates :postal_code, presence: true, if: -> { Setting.force_presence_postal_code? }
  validates :year_of_birth, presence: true, unless: -> { Setting.force_presence_date_of_birth? }

  validate :allowed_age
  validate :local_residence

  def save
    return false unless valid?

    document_owner = User.with_hidden.by_document(document_type, document_number).first

    if document_owner.present?
      self.user = document_owner
      user.update!(verified_at: Time.current)
    else
      user_params = {
        document_number: document_number,
        document_type: document_type,
        residence_verified_at: Time.current
      }

      self.user = User.create_from_census_response!(@census_api_response, user_params)
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
      date_of_birth: date_of_birth,
      postal_code: postal_code,
      year_of_birth: year_of_birth,
      poll_officer: officer
    )
  end

  def local_residence
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:local_residence, false)
    end
  end

  def allowed_age
    return if errors[:year_of_birth].any?
    return unless @census_api_response.valid?

    unless allowed_age?
      errors.add(:year_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
    end
  end

  def allowed_age?
    Age.in_years(response_date_of_birth) >= User.minimum_required_age
  end

  def response_date_of_birth
    @census_api_response.date_of_birth
  end

  private

    def retrieve_census_data
      @census_api_response = CensusCaller.new.call(document_type,
                                                   document_number,
                                                   date_of_birth,
                                                   postal_code)
    end

    def residency_valid?
      @census_api_response.valid? && valid_year_of_birth?
    end

    def valid_year_of_birth?
      return true if Setting.force_presence_date_of_birth?

      @census_api_response.date_of_birth.year.to_s == year_of_birth.to_s
    end
end
