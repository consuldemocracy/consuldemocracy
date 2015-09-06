class Verification::Sms
  include ActiveModel::Model

  attr_accessor :user, :phone, :confirmation_code

  validates_presence_of :phone
  validates :phone, length: { is: 9 }
  validate :spanish_phone
  validate :uniqness_phone

  def spanish_phone
    errors.add(:phone, :invalid) unless phone.start_with?('6', '7')
  end

  def uniqness_phone
    errors.add(:phone, :taken) if User.where(confirmed_phone: phone).any?
  end

  def save
    return false unless self.valid?
    update_user_phone_information
    send_sms
    increase_sms_tries
  end

  def update_user_phone_information
    user.update(unconfirmed_phone: phone, sms_confirmation_code: four_digit_code)
  end

  def send_sms
    SMSApi.new.sms_deliver(user.unconfirmed_phone, user.sms_confirmation_code)
  end

  def increase_sms_tries
    user.update(sms_confirmation_tries: user.sms_confirmation_tries += 1)
  end

  def verify?
    user.sms_confirmation_code == confirmation_code
  end

  def user_is_locked?
    Rails.cache.read("sms_verifier_locked_user_#{user.id}")||user.sms_confirmation_tries>=3&&lock_user!
  end

  def lock_user!
    expire_lock_in_minutes = 3.minutes
    user.update_attributes sms_confirmation_tries: 0
    Rails.cache.write("sms_verifier_locked_user_#{user.id}",true, expires_in: expire_lock_in_minutes)
    true
  end

  private

    def four_digit_code
      rand.to_s[2..5]
    end
end