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
      attrs = record.attributes

      if attrs["created_at"]
        attrs["created_at"] = I18n.l(record.created_at, format: :api)
      end

      attrs.values_at(*columns(record_model(record)))
    end

    def record_model(record)
      record.class.name.demodulize.underscore.pluralize
    end

    def filename(table)
      [folder, table, '.csv'].join
    end

    def folder
      "#{Rails.root}/public/api/"
    end

end