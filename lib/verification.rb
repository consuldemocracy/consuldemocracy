module Verification

  def verification_email_sent?
    email_verification_token.present?
  end

  def verification_sms_sent?
    unconfirmed_phone.present? && sms_confirmation_code.present?
  end

  def verification_letter_sent?
    letter_requested_at.present? && letter_verification_code.present?
  end

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