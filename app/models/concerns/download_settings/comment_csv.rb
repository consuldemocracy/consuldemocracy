module DownloadSettings
  module CommentCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names(config)
      DownloadSetting.where(name_model: "Comment",
                            downloadable: true,
                            config: config).pluck(:name_field)
    end

    def to_csv(comments, admin_attr, options = {})

      attributes = admin_attr.nil? ? [] : admin_attr

      CSV.generate(options) do |csv|
        csv << attributes
        comments.each do |comment|
          csv << attributes.map {|attr| comment.send(attr)}
        end
      end
    end

  end
end
