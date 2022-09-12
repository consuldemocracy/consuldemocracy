require_dependency Rails.root.join("app", "models", "image").to_s

class Image < ApplicationRecord
  has_attached_file :attachment, styles: {
                                   large: "x#{Setting["uploads.images.min_height"]}",
                                   medium: "300x300#",
                                   thumb: "140x245#"
                                 },
                                 url: "#{Rails.application.config.root_directory}/system/:class/:prefix/:style/:hash.:extension",
                                 path: ":rails_root/public#{Rails.application.config.root_directory}/system/:class/:prefix/:style/:hash.:extension",
                                 hash_data: ":class/:style",
                                 use_timestamp: false,
                                 hash_secret: Rails.application.secrets.secret_key_base
end
