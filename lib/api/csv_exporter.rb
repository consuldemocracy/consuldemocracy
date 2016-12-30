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
        model(table).all.limit(2).each do |record|
          if api_record(record).public?
            csv << public_attributes(record)
          end
        end
      end
    end

    def public_attributes

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

    def api_record(record)
       "API::#{record.class}".constantize.new(record.id)
    end

    def public_attributes(record)
      record.attributes.values_at(*columns(record.class.name.underscore.pluralize))
    end

    def filename(table)
      [folder, table, '.csv'].join
    end

    def folder
      "tmp/"
    end

end