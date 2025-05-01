class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :date_of_birth, :date
  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

#  validates :document_number, presence: true
#  validates :document_type, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting["min_age_to_participate"].present? }
  validates :postal_code, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }

  validate :allowed_age, if: -> { Setting["min_age_to_participate"].present? }
 # validate :document_number_uniqueness

  validate :local_postal_code
  #validate :local_residence

  def initialize(attrs = {})
    super
#    clean_document_number
  end

  def save
    return false unless valid?

  #  user.take_votes_if_erased_document(document_number, document_type)

    user.update(#document_number: document_number,
                #document_type: document_type,
                geozone_id: my_geozone,
                date_of_birth: date_of_birth.present? ? date_of_birth.in_time_zone.to_datetime : nil,
#               date_of_birth: date_of_birth.in_time_zone.to_datetime,
 #              gender: gender,
                residence_verified_at: Time.current,
                verified_at: Time.current)             
  end

  def save!
    validate! && save
  end

  def allowed_age
    return if errors[:date_of_birth].any? || Age.in_years(Date.parse(date_of_birth)) >= User.minimum_required_age

    errors.add(:date_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
  end

  def document_number_uniqueness
    if User.active.where(document_number: document_number).any?
      errors.add(:document_number, I18n.t("errors.messages.taken"))
    end
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

  def my_geozone
  # Initialize saml_geozone_id
    geozone_id = nil
    # Assign Geozone based on the normalized saml_postcode if it exists
    if postal_code.present?  # Find the Postcode instance based on the normalized saml_postcode
      puts "about to check: #{postal_code}"
      geozone_id = Postcode.find_geozone_for_postcode(postal_code)
   end
   geozone_id
  #  Geozone.find_by(census_code: district_code)
  end
  
  def verify_dob
    Setting["min_age_to_participate"].present?
  end
  
  def district_code
    census_data.district_code
  end

  def gender
    census_data&.gender
  end

  def local_postal_code
    errors.add(:postal_code,
               I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  def local_residence
    return if errors.any?

    unless residency_valid?
      errors.add(:local_residence, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def census_data
      @census_data ||= CensusCaller.new.call(document_type, document_number, date_of_birth, postal_code)
    end

    def residency_valid?
    #  census_data.valid? &&
    #    census_data.postal_code == postal_code &&
    #    census_data.date_of_birth == date_of_birth
    true
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

    def valid_postal_code?
      return true if Setting["postal_codes"].blank?

      Setting["postal_codes"].split(",").any? do |code_or_range|
        if code_or_range.include?(":")
          Range.new(*code_or_range.split(":").map(&:strip)).include?(postal_code&.strip)
        else
          /\A#{code_or_range.strip}\Z/.match?(postal_code&.strip)
        end
      end
    end
end
