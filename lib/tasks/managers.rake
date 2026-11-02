namespace :managers do
  desc "Removes duplicate managers"
  task remove_duplicate_managers: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate managers"

    Tenant.run_on_each do
      duplicate_user_ids = Manager.select(:user_id)
                                  .group(:user_id)
                                  .having("count(*) > 1")
                                  .pluck(:user_id)

      duplicate_user_ids.each do |user_id|
        managers = Manager.where(user_id: user_id).order(:id)
        valid_manager = managers.first

        managers.excluding(valid_manager).each do |manager|
          manager.delete

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{manager.id} " \
                        "from the #{Manager.table_name} table " \
                        "with user_id #{user_id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
