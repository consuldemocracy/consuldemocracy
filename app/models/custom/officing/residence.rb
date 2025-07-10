require_dependency Rails.root.join("app", "models", "officing", "residence").to_s

class Officing::Residence
  validate :residence_in_valladolid

  def residence_in_valladolid
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:residence_in_valladolid, false)
    end
  end
end
