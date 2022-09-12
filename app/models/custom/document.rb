require_dependency Rails.root.join("app", "models", "document").to_s

class Document < ApplicationRecord
  has_attached_file :attachment, url: "#{Rails.application.config.root_directory}/system/:class/:prefix/:style/:hash.:extension",
                                 path: ":rails_root/public#{Rails.application.config.root_directory}/system/:class/:prefix/:style/:hash.:extension",
                                 hash_data: ":class/:style/:custom_hash_data",
                                 use_timestamp: false,
                                 hash_secret: Rails.application.secrets.secret_key_base
end
