require_dependency Rails.root.join("app", "models", "site_customization", "image").to_s

class SiteCustomization::Image < ApplicationRecord
  has_attached_file :image,
    path: "#{Rails.application.config.root_directory}/system/:class/:id_partition/:style/:basename.:extension",
    url: ":rails_root/public#{Rails.application.config.root_directory}/system/:class/:id_partition/:style/:basename.:extension"
end
