namespace :identities do
  desc "Removes duplicate identities"
  task remove_duplicate_identities: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate identities"

    Tenant.run_on_each do
      duplicate_ids = Identity.select(:provider, :uid)
                              .group(:provider, :uid)
                              .having("count(*) > 1")
                              .pluck(:provider, :uid)

      duplicate_ids.each do |provider, uid|
        identities = Identity.where(provider: provider, uid: uid).order(:id)
        valid_identity = identities.find(&:user_id) || identities.first

        identities.excluding(valid_identity).each do |identity|
          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?

          if identity.user_id == valid_identity.user_id || !identity.user_id
            identity.delete
            log_message = "Deleted duplicate record with ID #{identity.id} " \
                          "from the #{Identity.table_name} table " \
                          "with provider #{provider} and uid #{uid}" \
                          + tenant_info.to_s
            logger.info(log_message)
            duplicate_records_logger.info(log_message)
          else
            log_message = "Skipping identities with IDs #{valid_identity.id} " \
                          "and #{identity.id}, with provider #{provider} and " \
                          "uid #{uid}, because they're assigned to different " \
                          "users, with user_ids #{valid_identity.user_id} " \
                          "and #{identity.user_id}" + tenant_info.to_s +
                          ". Review these identities manually and update them " \
                          "(or delete one of them)."
            logger.warn(log_message)
            duplicate_records_logger.warn(log_message)
          end
        end
      end
    end
  end
end
