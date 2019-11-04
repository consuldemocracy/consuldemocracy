module Csv
  extend ActiveSupport::Concern

  class_methods do
    def get_downloadables_names
      DownloadSetting.where(name_model: name, downloadable: true).pluck(:name_field)
    end

    def get_association_attribute_names
      ["author_name", "author_email"].select { |field| attribute_method?(field) }
    end

    def to_csv(attributes)
      CSV.generate do |csv|
        csv << attributes
        all.each do |record|
          csv << attributes.map { |attr| record.send(attr) }
        end
      end
    end
  end
end
