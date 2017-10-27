
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

# REQUIREMENT TOL-2: Redefine Census verification model to use custom Toledo's service
class Verification::Residence

  before_validation :retrieve_toledo_census_data

  validate :postal_code_in_toledo
  validate :residence_in_toledo

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

  def valid_postal_code?
    postal_code =~ /^450/
  end

  def retrieve_toledo_census_data
    # REQUIREMENT TOL-2: Check citizen in census using custom Census Caller
    @census_data = ToledoCensusCaller.new.call(document_type, document_number)
  end
end
