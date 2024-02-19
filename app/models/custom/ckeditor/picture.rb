require_dependency Rails.root.join("app", "models", "ckeditor", "picture").to_s

class Ckeditor::Picture
  validates :storage_data, file_content_type: { allow: /^image\/.*/ }, file_size: { less_than: 50.megabytes }
end
