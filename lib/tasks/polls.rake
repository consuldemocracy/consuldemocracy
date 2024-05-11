namespace :polls do
  desc "Removes duplicate poll voters"
  task remove_duplicate_voters: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new

    logger.info "Removing duplicate voters in polls"

    Tenant.run_on_each do
      duplicate_ids = Poll::Voter.select(:user_id, :poll_id)
                                 .group(:user_id, :poll_id)
                                 .having("count(*) > 1")
                                 .pluck(:user_id, :poll_id)

      duplicate_ids.each do |user_id, poll_id|
        voters = Poll::Voter.where(user_id: user_id, poll_id: poll_id)
        voters.excluding(voters.first).each do |voter|
          voter.delete

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{voter.id} " \
                        "from the #{Poll::Voter.table_name} table " \
                        "with user_id #{user_id} " \
                        "and poll_id #{poll_id}" + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
