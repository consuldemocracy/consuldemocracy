namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    I18n.enforce_available_locales = false
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Resets the database and loads it from db/demo_seeds.rb"
  task :demo_seed, [:print_log] => [:truncate_all] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    load Rails.root.join("db", "demo_seeds.rb")
  end

  # TODO: replace with db:truncate_all when upgrading to Rails 6
  desc "Removes all data from all tables and resets sequences"
  task truncate_all: :environment do
    internal_tables = [
      ActiveRecord::Base.internal_metadata_table_name,
      ActiveRecord::Base.schema_migrations_table_name
    ]
    tables = ActiveRecord::Base.connection.tables - internal_tables

    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{tables.join(", ")} RESTART IDENTITY")
  end
end
