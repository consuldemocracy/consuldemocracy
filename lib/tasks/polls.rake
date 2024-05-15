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

  desc "Removes duplicate poll answers"
  task remove_duplicate_answers: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new

    logger.info "Removing duplicate answers in polls"

    Tenant.run_on_each do
      duplicate_ids = Poll::Answer.where(option_id: nil)
                                  .select(:question_id, :author_id, :answer)
                                  .group(:question_id, :author_id, :answer)
                                  .having("count(*) > 1")
                                  .pluck(:question_id, :author_id, :answer)

      duplicate_ids.each do |question_id, author_id, answer|
        poll_answers = Poll::Answer.where(question_id: question_id, author_id: author_id, answer: answer)

        poll_answers.excluding(poll_answers.first).each do |poll_answer|
          poll_answer.delete

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{poll_answer.id} " \
                        "from the #{Poll::Answer.table_name} table " \
                        "with question_id #{question_id}, " \
                        "author_id #{author_id} " \
                        "and answer #{answer}" + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
