require 'csv'
class API::CSVExporter

    def initialize(print_log: false)
      @print_log = print_log
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
      print "\nExporting #{model.model_name.human}" if @print_log
      counter = 0
      CSV.open(filename(model), "w") do |csv|
        csv << model.public_columns_for_api
        model.find_each do |record|
          if record.public_for_api?
            csv << public_attributes(record)
            counter += 1
            if counter == 1000
              counter = 0
              print('.') if @print_log
            end
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
