namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:tenant] => [:environment] do |_, args|
    I18n.enforce_available_locales = false
    Tenant.switch(args[:tenant]) { load(Rails.root.join("db", "dev_seeds.rb")) }
  end

  desc "Resets the database and loads it from db/demo_seeds.rb"
  task :demo_seed, [:tenant] => [:environment] do |_, args|
    Tenant.switch(args[:tenant]) { load Rails.root.join("db", "demo_seeds.rb") }
  end
end
