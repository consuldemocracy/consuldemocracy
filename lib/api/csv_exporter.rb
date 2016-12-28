require 'csv'
class API::CSVExporter

    def initialize
    end

    def tables
      ["proposals"]
    end

    def export(options = {})
      tables.each do |table|
        generate_csv(table)
      end
    end

    def generate_csv(table)
      CSV.open(filename(table), "w") do |csv|
        csv << columns(table)
        model(table).all.limit(2).each do |record|
          csv << record.public_attributes
        end
      end
    end

    def columns(table)
      "API::#{model_name(table)}".constantize.public_columns
    end

    def model(table)
      "::#{model_name(table)}".constantize
    end

    def model_name(table)
      table.camelcase.singularize
    end

    def filename(table)
      [folder, table, '.csv'].join
    end

    def folder
      "tmp/"
    end

end