namespace :local_census_records do
  desc "Remove duplicated records from database"
  task remove_duplicates: :environment do
    ids = LocalCensusRecord.group(:document_type, :document_number).pluck("MIN(id) as id")
    duplicates = LocalCensusRecord.count - ids.size

    if duplicates > 0
      ApplicationLogger.new.info "Removing local census records duplicates"
      LocalCensusRecord.where("id NOT IN (?)", ids).destroy_all
      ApplicationLogger.new.info "Removed #{duplicates} records."
    end
  end
end
