namespace :csv do
  desc "Creates CSV files from the main tables"
  task export: :environment do
    API::CSVExporter.new.export
  end
end
