Devise.setup do |config|
  # ==> Security Extension
  # Configure security extension for devise

  # Should the password expire (e.g 3.months)
  config.expire_password_after = 1.year

  # Need 1 char each of: A-Z, a-z, 0-9, and a punctuation mark or symbol
  # You may use "digits" in place of "digit" and "symbols" in place of
  # "symbol" based on your preference
  config.password_complexity = { digit: 0, lower: 0, symbol: 0, upper: 0 }

  # How many passwords to keep in archive
  # config.password_archiving_count = 5

  # Deny old passwords (true, false, number_of_old_passwords_to_check)
  # Examples:
  # config.deny_old_passwords = false # allow old passwords
  # config.deny_old_passwords = true # will deny all the old passwords
  # config.deny_old_passwords = 3 # will deny new passwords that matches with the last 3 passwords

  # enable email validation for :secure_validatable. (true, false, validation_options)
  # dependency: see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation
  config.email_validation = false

  # captcha integration for recover form
  # config.captcha_for_recover = true

  # captcha integration for sign up form
  # config.captcha_for_sign_up = true

  # captcha integration for sign in form
  # config.captcha_for_sign_in = true

  # captcha integration for unlock form
  # config.captcha_for_unlock = true

  # captcha integration for confirmation form
  # config.captcha_for_confirmation = true

  # Time period for account expiry from last_activity_at
  # config.expire_after = 90.days

  # Allow password to equal the email
  config.allow_passwords_equal_to_email = true
end

module Devise
  module Models
    module PasswordExpirable
      def need_change_password?
        administrator? && password_expired?
      end

      def password_expired?
        password_changed_at < expire_password_after.ago
      end
    end

    module SecureValidatable
      def current_equal_password_validation
        if !new_record? && !encrypted_password_change.nil? && !erased?
          dummy = self.class.new
          dummy.encrypted_password = encrypted_password_change.first

          if respond_to?(:password_salt_change) && !password_salt_change.nil?
            dummy.password_salt = password_salt_change.first
          end

          errors.add(:password, :equal_to_current_password) if dummy.valid_password?(password)
        end
      end
    end
  end
end
