class DownloadSetting < ApplicationRecord
  validates :model, presence: true
  validates :field, presence: true

  def self.initialize(model, field_name)
    download_setting = DownloadSetting.find_by(model: model.name,
                                               field: field_name)
    if download_setting.nil?
      download_setting = DownloadSetting.create!(downloadable: false,
                                                 model: model.name,
                                                 field: field_name)
    end
    download_setting
  end
end
