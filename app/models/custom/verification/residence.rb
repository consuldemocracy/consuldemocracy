
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_penalolen
  validate :residence_in_penalolen

  def postal_code_in_penalolen
    abre_log
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_penalolen
    abre_log
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_penalolen, false)
      # store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      abre_log
      postal_code =~ /^791/
      # true
    end

end
