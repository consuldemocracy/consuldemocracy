module DownloadSettings
  module LegislationProcessCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      []
    end

    def get_downloadables_names
      DownloadSetting.where(name_model: "Legislation::Process", downloadable: true).pluck(:name_field)
    end

    def to_csv(attributes)
      CSV.generate do |csv|
        csv << attributes
        all.each do |process|
          csv << attributes.map { |attr| process.send(attr) }
        end
      end
    end
  end
end
