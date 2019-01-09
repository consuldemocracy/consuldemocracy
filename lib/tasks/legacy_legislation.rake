namespace :legacy_legislation do

  desc "Migrates LegacyLegislation processes to Legislation::Process"
  task migrate_processes: :environment do
    require "migrations/legacy_legislation/process"
    Migrations::LegacyLegislation::Process.new.migrate_processes
  end

end
