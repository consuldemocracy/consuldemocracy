class SetRegistrationVerificatedFields

  def self.call user
    self.new(user).call
  end

  def initialize user
    @user = user
  end

  def call
    set_verification_fields unless @user.new_record?
  end

  private

  def set_verification_fields
    @user.residence_verified_at = Time.zone.now
    @user.verified_at           = Time.zone.now
    @user.level_two_verified_at = Time.zone.now
    @user.confirmed_phone       = @user.phone_number
    @user.save
  end

end
