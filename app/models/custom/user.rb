require_dependency Rails.root.join('app', 'models', 'user').to_s

class User < ActiveRecord::Base

  GENDERS = %w(male female).freeze

  validates :firstname,
            :lastname,
            :date_of_birth,
            :postal_code,
            presence: true, if: :username_required?

  private def set_default_username
    self.username = [lastname, firstname].join(" ")
  end
  before_validation :set_default_username, if: -> { username.blank? && !erased? }

  # Instance methods ==================================================

  def erase(erase_reason = nil)
    update(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil,
      firstname: nil,
      lastname: nil,
      postal_code: nil,
      date_of_birth: nil
    )
    identities.destroy_all
  end


end
