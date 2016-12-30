require 'csv'
class API::CSVExporter

    def initialize
    end

    def tables
      ["proposals",
       "debates",
       "comments",
       "geozones",
       "proposal_notifications",
       "tags",
       "taggings",
       "votes"]
    end

    def export(options = {})
      tables.each do |table|
        generate_csv(table)
      end
    end

    def generate_csv(table)
      CSV.open(filename(table), "w") do |csv|
        csv << columns(table)
        model(table).all.each do |record|
          if record.public_for_api?
            csv << public_attributes(record)
          end
        end
      end
    end

    def columns(table)
      model_name(table).constantize.public_columns_for_api
    end

    def model(table)
      "::#{model_name(table)}".constantize
    end

    def model_name(table)
      table.camelcase.singularize
    end

    def public_attributes(record)
      record.attributes.values_at(*columns(record.class.name.underscore.pluralize))
    end

    def filename(table)
      [folder, table, '.csv'].join
    end

    def folder
      "public/"
    end

end