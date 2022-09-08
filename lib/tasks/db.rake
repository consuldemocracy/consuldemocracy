namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    I18n.enforce_available_locales = false
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Calculates the TSV column for all comments and proposal notifications"
  task calculate_tsv: :environment do
    logger = ApplicationLogger.new

    logger.info "Calculating tsvector for comments"
    Comment.with_hidden.find_each(&:calculate_tsvector)

    logger.info "Calculating tsvector for proposal notifications"
    ProposalNotification.with_hidden.find_each(&:calculate_tsvector)
  end
end
