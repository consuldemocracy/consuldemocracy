# config/initializers/active_record_encryption.rb
# This initializer configures ActiveRecord encryption using keys from secrets.yml
# Note: We use Rails.application.secrets directly here because Tenant model isn't loaded yet

if Rails.application.config.respond_to?(:active_record) &&
   Rails.application.config.active_record.respond_to?(:encryption=)

  # Get encryption config directly from Rails secrets (not Tenant, which isn't loaded yet)
  encryption_config = Rails.application.secrets[:active_record_encryption]

  if encryption_config.present? &&
     encryption_config[:primary_key].present? &&
     encryption_config[:deterministic_key].present? &&
     encryption_config[:key_derivation_salt].present?

    # Configure ActiveRecord encryption with the keys from secrets.yml
    Rails.application.config.active_record.encryption = {
      primary_key: encryption_config[:primary_key],
      deterministic_key: encryption_config[:deterministic_key],
      key_derivation_salt: encryption_config[:key_derivation_salt]
    }

    Rails.logger.info "✅ ActiveRecord encryption configured from secrets.yml"

    # Optional: Log a masked version of the keys for debugging
    Rails.logger.info "   primary_key: #{encryption_config[:primary_key][0..10]}...[masked]"
    Rails.logger.info "   deterministic_key: #{encryption_config[:deterministic_key][0..10]}...[masked]"
    Rails.logger.info "   key_derivation_salt: #{encryption_config[:key_derivation_salt][0..10]}...[masked]"
  else
    Rails.logger.warn "⚠️  ActiveRecord encryption keys not found in secrets.yml"
    Rails.logger.warn "   Required keys under :active_record_encryption:"
    Rails.logger.warn "     - primary_key"
    Rails.logger.warn "     - deterministic_key"
    Rails.logger.warn "     - key_derivation_salt"
    Rails.logger.warn "   Current secrets keys: #{Rails.application.secrets.keys.inspect}"
    Rails.logger.warn "   Run 'rails two_factor:generate_keys' to generate the required keys"
  end
end
