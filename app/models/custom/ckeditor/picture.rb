require_dependency Rails.root.join("app", "models", "ckeditor", "picture").to_s

class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    url: "#{Rails.application.config.root_directory}/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                    path: ":rails_root/public#{Rails.application.config.root_directory}/ckeditor_assets/pictures/:id/:style_:basename.:extension",
                    styles: { content: "800>", thumb: "118x100#" }
end
