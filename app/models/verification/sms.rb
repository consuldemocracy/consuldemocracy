class Verification::Sms
  include ActiveModel::Model

  attr_accessor :user, :phone, :confirmation_code

  validates_presence_of :phone
  validates :phone, format: { with: /\A[\d \+]+\z/ }
  validate :uniqness_phone

  def uniqness_phone

    errors.add(:phone, :taken) if User.where(confirmed_phone: normalized_phone).any?
  end

  def normalized_phone
    normalized = PhonyRails.normalize_number(phone.gsub('+',''), default_country_code: 'ES',  strict: true)
  end

  def save
    return false unless self.valid?
    update_user_phone_information
    send_sms
    Lock.increase_tries(user)
  end

  def update_user_phone_information
    pin = generate_confirmation_code
    user.update(unconfirmed_phone: normalized_phone, sms_confirmation_code: pin)

    # Security
    # One time pin by normalized phone
    SmsOtp.create_or_update(normalized_phone, pin)
  end

  def send_sms
    SMSApiCustom.new.sms_deliver(user.unconfirmed_phone, user.sms_confirmation_code)
  end

  def verified?
    (user.sms_confirmation_code == confirmation_code) && SmsOtp.is_confirmed?(user.unconfirmed_phone, confirmation_code)
  end

  private

    def generate_confirmation_code
      rand.to_s[2..5]
    end
end
