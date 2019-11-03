class DownloadSetting < ApplicationRecord
  validates :name_model, presence: true
  validates :name_field, presence: true

  def self.initialize(model, field_name)
    download_setting = DownloadSetting.find_by(name_model: model.name,
                                               name_field: field_name)
    if download_setting.nil?
      download_setting = DownloadSetting.create!(downloadable: false,
                                                 name_model: model.name,
                                                 name_field: field_name)
    end
    download_setting
  end
end
