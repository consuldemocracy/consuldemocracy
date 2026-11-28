namespace :poll_officers do
  desc "Removes duplicate poll officers"
  task remove_duplicate_poll_officers: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate poll officers"

    Tenant.run_on_each do
      duplicate_user_ids = Poll::Officer.select(:user_id)
                                        .group(:user_id)
                                        .having("count(*) > 1")
                                        .pluck(:user_id)

      duplicate_user_ids.each do |user_id|
        officers = Poll::Officer.where(user_id: user_id).order(:id)
        valid_officer = officers.first

        officers.excluding(valid_officer).each do |officer|
          RoleDeduplicator.new(valid_officer, officer).deduplicate

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{officer.id} " \
                        "from the #{Poll::Officer.table_name} table " \
                        "with user_id #{user_id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
