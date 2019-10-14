class SmsOtp < ActiveRecord::Base

  def self.create_or_update(normalized_phone, confirmation_code)

    phone_pin = SmsOtp.find_by_phone_number(normalized_phone)

    if phone_pin.nil?
      SmsOtp.create(phone_number:normalized_phone, confirmation_code: confirmation_code)
    else
      phone_pin.update( confirmation_code: confirmation_code)
    end
  end

  def self.is_confirmed?(normalized_phone, confirmation_code)
    phone_pin = SmsOtp.find_by_phone_number(normalized_phone)
    return false if phone_pin.nil?

    phone_pin.confirmation_code == confirmation_code
  end
end
