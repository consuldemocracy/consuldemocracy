class Ckeditor::Picture < Ckeditor::Asset
  include HasAttachment

  has_attachment :data,
                 url: "/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                 path: ":rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                 styles: { content: "800>", thumb: "118x100#" }

  do_not_validate_attachment_file_type :data
  validate :attachment_presence
  validates :data, file_content_type: { allow: /^image\/.*/ }, file_size: { less_than: 2.megabytes }

  def url_content
    url(:content)
  end

  private

    def attachment_presence
      unless data.present?
        errors.add(:data, I18n.t("errors.messages.blank"))
      end
    end
end
