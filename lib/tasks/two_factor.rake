# lib/tasks/two_factor.rake
namespace :two_factor do
  desc "Generate 2FA encryption keys for a specific environment (default: development)"
  task :generate_keys, [:environment] => :environment do |t, args|
    env = args[:environment] || Rails.env
    puts "\n" + "=" * 60
    puts "Generate these keys and add them to config/secrets.yml under '#{env}'"
    puts "=" * 60 + "\n\n"

    puts "# For the #{env} environment, add:"
    puts "\n#{env}:"
    puts "  devise_otp_key: #{SecureRandom.hex(32)}"
    puts "  "
    puts "  active_record_encryption:"
    puts "    primary_key: #{SecureRandom.hex(32)}"
    puts "    deterministic_key: #{SecureRandom.hex(32)}"
    puts "    key_derivation_salt: #{SecureRandom.hex(32)}"
    puts "\n" + "=" * 60 + "\n"
  end

  desc "Check 2FA configuration for current environment"
  task check_config: :environment do
    secrets = Tenant.current_secrets

    puts "\n2FA Configuration Check for #{Rails.env} environment:"
    puts "=" * 50

    if secrets[:devise_otp_key].present?
      puts "✅ devise_otp_key: Present"
    else
      puts "❌ devise_otp_key: MISSING"
    end

    encryption = secrets[:active_record_encryption]
    if encryption.present?
      puts "\nactive_record_encryption:"
      if encryption[:primary_key].present?
        puts "  ✅ primary_key: Present"
      else
        puts "  ❌ primary_key: MISSING"
      end

      if encryption[:deterministic_key].present?
        puts "  ✅ deterministic_key: Present"
      else
        puts "  ❌ deterministic_key: MISSING"
      end

      if encryption[:key_derivation_salt].present?
        puts "  ✅ key_derivation_salt: Present"
      else
        puts "  ❌ key_derivation_salt: MISSING"
      end
    else
      puts "❌ active_record_encryption section: MISSING"
    end

    puts "=" * 50

    # Check if 2FA can work
    if two_factor_fully_configured?(secrets)
      puts "✅ 2FA is FULLY CONFIGURED for #{Rails.env}"
    else
      puts "❌ 2FA is NOT FULLY CONFIGURED for #{Rails.env}"
      puts "\nRun: rails two_factor:generate_keys[#{Rails.env}] to get the required keys"
    end
  end

  private

    def two_factor_fully_configured?(secrets)
      secrets[:devise_otp_key].present? &&
        secrets.dig(:active_record_encryption, :primary_key).present? &&
        secrets.dig(:active_record_encryption, :deterministic_key).present? &&
        secrets.dig(:active_record_encryption, :key_derivation_salt).present?
    end
end
