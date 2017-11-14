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
      CSV.open(filename(model), "w", col_sep: ';', force_quotes: true, encoding: "ISO-8859-1") do |csv|
        csv << encode_array(model.public_columns_for_api)
        model.public_for_api.order(:id).find_each do |record|
          csv << encode_array(public_attributes(record))
          counter += 1
          if counter == 1000
            counter = 0
            print('.') if @print_log
          end
        end
      end
    end

    def encode_array(values)
      values.map{|v| v.to_s.encode("ISO-8859-1", invalid: :replace, undef: :replace, replace: '')}
    end

    def public_attributes(record)
      attrs = record.attributes.dup
      attrs["created_at"] = I18n.l(attrs["created_at"], format: :api) if attrs["created_at"]
      attrs.values_at(*record.class.public_columns_for_api)
    end

    def filename(model)
      [folder, model.table_name, '.csv'].join
    end

    def folder
      "public/system/api/"
    end

end
