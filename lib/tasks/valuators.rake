namespace :valuators do
  desc "Removes duplicate valuators"
  task remove_duplicate_valuators: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate valuators"

    Tenant.run_on_each do
      duplicate_user_ids = Valuator.select(:user_id)
                                   .group(:user_id)
                                   .having("count(*) > 1")
                                   .pluck(:user_id)

      duplicate_user_ids.each do |user_id|
        valuators = Valuator.where(user_id: user_id).order(:id)
        valid_valuator = valuators.first

        valuators.excluding(valid_valuator).each do |valuator|
          RoleDeduplicator.new(valid_valuator, valuator).deduplicate

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{valuator.id} " \
                        "from the #{Valuator.table_name} table " \
                        "with user_id #{user_id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
