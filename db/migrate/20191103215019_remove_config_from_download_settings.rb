class RemoveConfigFromDownloadSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :download_settings, :config, :integer, default: 0, null: false
  end
end
