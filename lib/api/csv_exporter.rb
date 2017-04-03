require 'csv'
class API::CSVExporter

    def initialize
    end

    def models
      [Proposal,
       Debate,
       Comment,
       Geozone,
       ProposalNotification,
       ActsAsTaggableOn::Tag,
       ActsAsTaggableOn::Tagging,
       Vote]
    end

    def export(options = {})
      models.each do |model|
        export_model(model)
      end
    end

    def export_model(model)
      puts "Exporting #{model.model_name.human} ..."
      CSV.open(filename(model), "w") do |csv|
        csv << model.public_columns_for_api
        model.all.each do |record|
          if record.public_for_api?
            csv << public_attributes(record)
          end
        end
      end
    end

    def public_attributes(record)
      record.attributes.values_at(*record.class.public_columns_for_api).map do |value|
        value.is_a?(DateTime) ? I18n.l(record.created_at, format: :api) : value
      end
    end

    def filename(model)
      [folder, model.table_name, '.csv'].join
    end

    def folder
      "public/api/"
    end

end
