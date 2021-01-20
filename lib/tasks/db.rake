namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Load SDG content into database"
  task load_sdg: :environment do
    ApplicationLogger.new.info "Adding Sustainable Development Goals content"
    load(Rails.root.join("db", "sdg.rb"))
    WebSection.where(name: "sdg").first_or_create!
  end

  desc "Calculates the TSV column for all polls and legislation processes"
  task calculate_tsv: :environment do
    Poll.find_each(&:calculate_tsvector)
    Legislation::Process.find_each(&:calculate_tsvector)
  end
end
