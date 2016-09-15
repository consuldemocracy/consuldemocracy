Devise.setup do |config|
  # ==> Security Extension
  # Configure security extension for devise

  # Should the password expire (e.g 3.months)
  # config.expire_password_after = false
  config.expire_password_after = 1.year

  # Need 1 char of A-Z, a-z and 0-9
  # config.password_regex = /(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])/

  # How many passwords to keep in archive
  # config.password_archiving_count = 5

  # Deny old password (true, false, count)
  # config.deny_old_passwords = true

  # enable email validation for :secure_validatable. (true, false, validation_options)
  # dependency: need an email validator like rails_email_validator
  # config.email_validation = true

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
end

module Devise
  module Models
    module PasswordExpirable
      def need_change_password?
        if self.administrator?
          #is administrator
          if self.expire_password_after.is_a? Fixnum or self.expire_password_after.is_a? Float
            self.password_changed_at.nil? or self.password_changed_at < self.expire_password_after.ago
          else
            #not change password
            false
          end
        else
          #It is not an administrator
          false
        end 
      end 
    end

    module SecureValidatable
      def self.included(base)
        base.extend ClassMethods
        assert_secure_validations_api!(base)

        base.class_eval do
          # validate login in a strict way if not yet validated
          unless devise_validation_enabled?
            validates :email, :presence => true, :if => :email_required?
            validates :email, :uniqueness => true, :allow_blank => true, :if => :email_changed? # check uniq for email ever
            validates :password, :presence => true, :length => password_length, :confirmation => true, :if => :password_required?
          end

          # extra validations
          #validates :password, :format => { :with => password_regex, :message => :password_format }, :if => :password_required?
          # don't allow use same password
          validate :current_equal_password_validation
        end
      end

      def self.assert_secure_validations_api!(base)
        raise "Could not use SecureValidatable on #{base}" unless base.respond_to?(:validates)
      end

      def current_equal_password_validation
        if !self.new_record? && !self.encrypted_password_change.nil? && !self.erased?
          dummy = self.class.new
          dummy.encrypted_password = self.encrypted_password_change.first
          dummy.password_salt = self.password_salt_change.first if self.respond_to? :password_salt_change and not self.password_salt_change.nil?
          self.errors.add(:password, :equal_to_current_password) if dummy.valid_password?(self.password)
        end
      end

      protected

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      def email_required?
        true
      end

      module ClassMethods
        Devise::Models.config(self, :password_regex, :password_length, :email_validation)

      private
        def has_uniqueness_validation_of_login?
          validators.any? do |validator|
            validator.kind_of?(ActiveRecord::Validations::UniquenessValidator) &&
              validator.attributes.include?(login_attribute)
          end
        end

        def login_attribute
          authentication_keys[0]
        end

        def devise_validation_enabled?
          self.ancestors.map(&:to_s).include? 'Devise::Models::Validatable'
        end
      end
    end
  end
end