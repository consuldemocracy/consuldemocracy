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
          identity.delete

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{identity.id} " \
                        "from the #{Identity.table_name} table " \
                        "with provider #{provider} and uid #{uid}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
