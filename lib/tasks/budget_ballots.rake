namespace :budget_ballots do
  desc "Removes duplicate budget ballots"
  task remove_duplicate_budget_ballots: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate budget ballots"

    Tenant.run_on_each do
      duplicate_ids = Budget::Ballot.where.not(user_id: nil)
                                    .group(:user_id, :budget_id)
                                    .having("count(*) > 1")
                                    .pluck(:user_id, :budget_id)

      duplicate_ids.each do |user_id, budget_id|
        ballots = Budget::Ballot.where(user_id: user_id, budget_id: budget_id).order(:id)
        valid_ballot = ballots.find { |ballot| ballot.lines.any? } || ballots.first

        ballots.excluding(valid_ballot).each do |ballot|
          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?

          if valid_ballot.lines.any? && ballot.lines.any?
            log_message = "Skipping ballots with IDs #{valid_ballot.id} " \
                          "and #{ballot.id}, with user_id #{user_id} and " \
                          "budget_id #{budget_id}, because both ballots " \
                          "contain investments. Review these ballots manually, " \
                          "update them, and delete one of them."
            logger.warn(log_message)
            duplicate_records_logger.warn(log_message)
          else
            ballot.destroy!

            log_message = "Deleted duplicate record with ID #{ballot.id} " \
                          "from the #{Budget::Ballot.table_name} table " \
                          "with user_id #{user_id} and budget_id #{budget_id}" \
                          + tenant_info.to_s
            logger.info(log_message)
            duplicate_records_logger.info(log_message)
          end
        end
      end
    end
  end
end
