namespace :moderators do
  desc "Removes duplicate moderators"
  task remove_duplicate_moderators: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate moderators"

    Tenant.run_on_each do
      duplicate_user_ids = Moderator.select(:user_id)
                                    .group(:user_id)
                                    .having("count(*) > 1")
                                    .pluck(:user_id)

      duplicate_user_ids.each do |user_id|
        moderators = Moderator.where(user_id: user_id).order(:id)
        valid_moderator = moderators.first

        moderators.excluding(valid_moderator).each do |moderator|
          ActiveRecord::Base.transaction do
            Comment.where(moderator_id: moderator.id).update_all(moderator_id: valid_moderator.id)
            moderator.delete
          end

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{moderator.id} " \
                        "from the #{Moderator.table_name} table " \
                        "with user_id #{user_id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
