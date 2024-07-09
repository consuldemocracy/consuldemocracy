require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  clear_validators!

  validates :date_of_birth, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, presence: true

  validate :allowed_age
  validate :allowed_postal_code
  validate :document_number_uniqueness_if_present

  def save
    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number:       document_number,
                document_type:         document_type,
                date_of_birth:         date_of_birth.in_time_zone.to_datetime,
                residence_verified_at: Time.current,
                verified_at: Time.current)
  end

  private

    def retrieve_census_data
      # Empty method because we don't check against census
    end

    def allowed_postal_code
      errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
    end

    def valid_postal_code?
      Zipcode.where(code: postal_code&.upcase).any?
    end

    def document_number_uniqueness_if_present
      if document_number.present?
        document_number_uniqueness
      end
    end
end
