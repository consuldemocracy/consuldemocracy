class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks
  include ApplicationHelper

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  before_validation :call_rut_api
  # before_validation :call_census_api

  validates_presence_of :document_number
  validates_presence_of :document_type
  validates_presence_of :date_of_birth
  validates_presence_of :postal_code
  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, length: { is: 7 }

  validate :allowed_age
  validate :document_number_uniqueness

  def initialize(attrs={})
    abre_log
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    clean_document_number
  end

  def save
    abre_log
    return false unless valid?
    abre_log 2
    user.take_votes_if_erased_document(document_number, document_type)

    if @rut_api_response
      abre_log
      abre_log 'rut_api_response is trueeeeeeeeeeeeeeeeeeeeeeeee'
      user.update(document_number:       document_number,
                  document_type:         document_type,
                  geozone:               Geozone.first,
                  date_of_birth:         date_of_birth.to_datetime,
                  gender:                1,
                  residence_verified_at: Time.current)

    end
    #
    # user.update(document_number:       document_number,
    #             document_type:         document_type,
    #             geozone:               self.geozone,
    #             date_of_birth:         date_of_birth.to_datetime,
    #             gender:                gender,
    #             residence_verified_at: Time.current)
  end

  def allowed_age
    abre_log
    return if errors[:date_of_birth].any?
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age')) unless Age.in_years(self.date_of_birth) >= User.minimum_required_age
  end

  def document_number_uniqueness
    abre_log
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.active.where(document_number: document_number).any?
  end

  def store_failed_attempt
    abre_log
    FailedCensusCall.create({
      user: user,
      document_number: document_number,
      document_type:   document_type,
      date_of_birth:   date_of_birth,
      postal_code:     postal_code
    })
  end

  def geozone
    abre_log
    Geozone.where(census_code: district_code).first
  end

  def district_code
    abre_log
    # @census_api_response.district_code
    1
  end

  def gender
    abre_log
    # @census_api_response.gender
    1
  end

  private

    def call_rut_api
      abre_log
      @rut_api_response = RutApi.new.call(document_number)
    end

    def call_census_api
      abre_log
      @census_api_response = CensusApi.new.call(document_type, document_number)
    end

    def residency_valid?
      abre_log
      # @census_api_response.valid? &&
      #   @census_api_response.postal_code == postal_code &&
      #   @census_api_response.date_of_birth == date_of_birth
      @rut_api_response
    end

    def clean_document_number
      abre_log
      self.document_number = self.document_number.gsub(/[^a-z0-9]+/i, "").upcase unless self.document_number.blank?
      abre_log self.document_number
    end

end
