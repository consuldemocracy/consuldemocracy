
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_getafe
  validate :residence_in_getafe

  def postal_code_in_getafe
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_getafe

    return if errors.any?
    unless residency_valid?
      errors.add(:residence_in_getafe, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end


  def district_code
    @census_api_response.district_name
  end

  def phone
    @census_api_response.phone_number
  end
  
  private

    def valid_postal_code?

      postal_code =~ /^289/
    end

    def residency_valid?
        # GET-37 || GET-44
        is_valid = @census_api_response.valid? && @census_api_response.valid? && @census_api_response.date_of_birth == date_of_birth
        is_valid
    end

    def call_census_api
      @census_api_response = CensusApiCustom.new.call(document_type, document_number)
    end
end
