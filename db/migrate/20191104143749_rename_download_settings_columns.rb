class RenameDownloadSettingsColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :download_settings, :name_model, :model
    rename_column :download_settings, :name_field, :field
  end
end
