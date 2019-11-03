module DownloadSettings
  module DebateCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names
      DownloadSetting.where(name_model: "Debate", downloadable: true).pluck(:name_field)
    end

    def to_csv(attributes)
      CSV.generate do |csv|
        csv << attributes
        all.each do |debate|
          csv << attributes.map { |attr| debate.send(attr) }
        end
      end
    end
  end
end
