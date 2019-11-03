module DownloadSettings
  module CommentCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names
      DownloadSetting.where(name_model: "Comment", downloadable: true).pluck(:name_field)
    end

    def to_csv(attributes)
      CSV.generate do |csv|
        csv << attributes
        all.each do |comment|
          csv << attributes.map { |attr| comment.send(attr) }
        end
      end
    end
  end
end
