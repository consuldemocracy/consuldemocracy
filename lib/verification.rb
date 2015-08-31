module Verification

  def residence_verified?
    residence_verified_at.present?
  end

  def sms_verified?
    confirmed_phone.present?
  end

  def level_two_verified?
    residence_verified? && sms_verified?
  end

  def level_three_verified?
    verified_at.present?
  end

  def unverified?
    !level_two_verified? && !level_three_verified?
  end


end