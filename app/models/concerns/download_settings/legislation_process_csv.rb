module DownloadSettings
  module LegislationProcessCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      []
    end

    def get_downloadables_names(config)
      DownloadSetting.where(name_model: "Legislation::Process",
                            downloadable: true,
                            config: config).pluck(:name_field)
    end

    def to_csv(processes, admin_attr, options = {})

      attributes = admin_attr.nil? ? [] : admin_attr

      CSV.generate(options) do |csv|
        csv << attributes
        processes.each do |process|
          csv << attributes.map{ |attr| process.send(attr)}
        end
      end
    end

  end
end
