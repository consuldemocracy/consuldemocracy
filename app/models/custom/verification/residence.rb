
# require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  before_validation :call_census_api

  validates_presence_of :document_number
  validates_presence_of :document_type
  validates_presence_of :date_of_birth
  validates_presence_of :postal_code

  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, length: { is: 5 }

  validate :successful_census_request
  validate :user_is_citizen?
  validate :valid_age?
  validate :same_date_of_birth?
  validate :document_number_uniqueness

  def initialize(attrs = {})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super(attrs)
    clean_document_number
  end

  def save
    return false unless valid? && @census_api_response.valid?

    user.update(
      document_number: document_number,
      document_type: document_type,
      date_of_birth: @census_api_response.census_date_of_birth,
      residence_verified_at: Time.now,
      verified_at: Time.now
    )
  end

  private

    def document_number_uniqueness
      if document_type.to_s == "1" || document_type.to_s == 3
        errors.add(:document_number, "Numero de documento inválido") if document_number.length != 9
      elsif (document_type.to_s == "1" || document_type.to_s == "3") && document_number.length >= 8
        errors.add(:document_number, I18n.t('errors.messages.taken')) if User.where("document_number like '" + document_number.to_s.first(8) + "%'" ).where("id != ?", user.id).any?
      elsif User.where(document_number: document_number).where("id != ?", user.id).any?
        errors.add(:document_number, I18n.t('errors.messages.taken'))
      end
    end

    def successful_census_request
      unless @census_api_response.valid?
        errors.add(:document_number, "Ha habido un error al consultar el censo")
      end
    end

    def valid_age?
      return if errors.any?

      unless @census_api_response.census_age >= 16
        errors.add(:date_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
      end
    end

    def call_census_api
      @census_api_response = CensusApi.new.call(document_type, document_number, postal_code)

      if Rails.env.production? && !user_is_citizen?
        store_failed_attempt
        Lock.increase_tries(user)
      end
    end

    def store_failed_attempt
      FailedCensusCall.create(
        user: user,
        document_number: document_number,
        document_type: document_type,
        date_of_birth: date_of_birth
      )
    end

    def user_is_citizen?
      return if errors.any?

      unless @census_api_response.is_citizen?
        errors.add(:document_number, "Este usuario no está empadronado")
      end
    end

    def same_date_of_birth?
      return if errors.any?

      unless date_of_birth == @census_api_response.census_date_of_birth
        errors.add(:date_of_birth, "La fecha de nacimiento no coincide")
      end
    end

    def clean_document_number
      self.document_number = self.document_number.gsub(/[^a-z0-9]+/i, "").upcase unless self.document_number.blank?
    end
end
