namespace :users do
  desc "Removes duplicate users"
  task remove_duplicate_users: :environment do
    logger = ApplicationLogger.new
    duplicate_records_logger = DuplicateRecordsLogger.new
    logger.info "Removing duplicate users with the same document"

    Tenant.run_on_each do
      duplicate_documents = User.where.not(document_number: nil)
                                .select(:document_type, :document_number)
                                .group(:document_type, :document_number)
                                .having("count(*) > 1")
                                .pluck(:document_type, :document_number)

      duplicate_documents.each do |document_type, document_number|
        users = User.where(document_type: document_type, document_number: document_number)
                    .order(Arel.sql("erased_at IS NOT NULL"), :id)
        valid_user = users.first

        users.excluding(valid_user).each do |duplicate_user|
          UserDeduplicator.new(valid_user, duplicate_user).deduplicate

          tenant_info = " on tenant #{Tenant.current_schema}" unless Tenant.default?
          log_message = "Deleted duplicate user with ID #{duplicate_user.id} " \
                        "with document type #{document_type} and document " \
                        "number ending with #{document_number.last(4)}, " \
                        "assigning their data to user with ID #{valid_user.id}" \
                        + tenant_info.to_s
          logger.info(log_message)
          duplicate_records_logger.info(log_message)
        end
      end
    end
  end
end
