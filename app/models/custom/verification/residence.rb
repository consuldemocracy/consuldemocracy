
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :residence_in_castellon

  def residence_in_castellon
    if !residency_valid?
      errors.add(:residence_in_castellon, false) if terms_of_service != '0'
      if user.persisted?
        store_failed_attempt
        Lock.increase_tries(user)
      end

    end
  end

  def save
    return false unless valid?
    user.update(document_number:       document_number,
                document_type:         document_type,
                geozone:               self.geozone,
                date_of_birth:         date_of_birth.to_datetime,
                gender:                gender,
                residence_verified_at: Time.current,
                confirmed_at: Time.current,
                verified_at: Time.current,
                unconfirmed_phone: '-',
                confirmed_phone: '-')
  end

  private

    def retrieve_census_data
      # @census_data = CensusCaller.new.call(document_type, document_number)
      @census_data = PadronCastellonApi.new.call(document_type, document_number)
    end

    def residency_valid?
      @census_data.valid? &&
        @census_data.date_of_birth == date_of_birth
    end

    def valid_postal_code?
      postal_code =~ /^12/
    end

end
