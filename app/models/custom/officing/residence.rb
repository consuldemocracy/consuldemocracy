require_dependency Rails.root.join("app", "models", "officing", "residence").to_s

class Officing::Residence
  validate :residence_in_pto_de_la_cruz

  def residence_in_pto_de_la_cruz
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:residence_in_pto_de_la_cruz, false)
    end
  end
end
