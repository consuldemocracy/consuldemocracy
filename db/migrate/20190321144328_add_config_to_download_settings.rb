class AddConfigToDownloadSettings < ActiveRecord::Migration
  def change
    add_column :download_settings, :config, :integer, default: 0, null: false

    remove_index :download_settings, name: "index_download_settings_on_name_model_and_name_field"
    add_index :download_settings, [:name_model, :name_field, :config], unique: true
  end
end
