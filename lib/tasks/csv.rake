namespace :csv do
  desc "Creates CSV files from the main tables"
  task export: :environment do
    API::CSVExporter.new(print_log: true).export
  end
end
