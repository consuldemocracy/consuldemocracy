require_dependency Rails.root.join("app", "models", "ckeditor", "attachment_file").to_s

class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data,
                    url: "#{Rails.application.config.root_directory}/ckeditor_assets/attachments/:id/:filename",
                    path: ":rails_root/public#{Rails.application.config.root_directory}/ckeditor_assets/attachments/:id/:filename"
end
