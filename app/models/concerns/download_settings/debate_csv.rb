module DownloadSettings
  module DebateCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names(config)
      DownloadSetting.where(name_model: "Debate",
                            downloadable: true,
                            config: config).pluck(:name_field)
    end

    def to_csv(debates, admin_attr, options = {})

      attributes = admin_attr.nil? ? [] : admin_attr

      CSV.generate(options) do |csv|
        csv << attributes
        debates.each do |debate|
          csv << attributes.map{ |attr| debate.send(attr)}
        end
      end
    end

  end
end
