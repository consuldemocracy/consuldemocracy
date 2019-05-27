namespace :stats_and_results do
  desc "Migrates stats_enabled and results_enabled data to enabled reports"
  task migrate_to_reports: :environment do
    Migrations::Reports.new.migrate
  end
end
