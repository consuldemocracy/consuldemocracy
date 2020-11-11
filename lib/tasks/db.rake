namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Load SDG goals and targets into database"
  task load_sdg: :environment do
    load(Rails.root.join("db", "sdg.rb"))
  end
end
