namespace :administrators do
  desc "Removes duplicate administrators"
  task remove_duplicate_administrators: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate administrators"

    Tenant.run_on_each do
      duplicate_user_ids = Administrator.select(:user_id)
                                        .group(:user_id)
                                        .having("count(*) > 1")
                                        .pluck(:user_id)

      duplicate_user_ids.each do |user_id|
        administrators = Administrator.where(user_id: user_id).order(:id)
        valid_administrator = administrators.first

        administrators.excluding(valid_administrator).each do |administrator|
          ActiveRecord::Base.transaction do
            budget_ids = BudgetAdministrator.where(administrator_id: valid_administrator.id)
                                            .pluck(:budget_id)
            BudgetAdministrator.where(administrator: administrator, budget_id: budget_ids)
                               .delete_all
            BudgetAdministrator.where(administrator: administrator)
                               .where.not(budget_id: budget_ids)
                               .update_all(administrator_id: valid_administrator.id)

            Budget::Investment.where(administrator: administrator)
                              .update_all(administrator_id: valid_administrator.id)
            Comment.where(administrator_id: administrator.id)
                   .update_all(administrator_id: valid_administrator.id)

            administrator.delete
          end

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate record with ID #{administrator.id} " \
                        "from the #{Administrator.table_name} table " \
                        "with user_id #{user_id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
