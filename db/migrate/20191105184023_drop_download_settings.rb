class DropDownloadSettings < ActiveRecord::Migration[5.0]
  def change
    drop_table :download_settings do |t|
      t.string  :name_model, null: false
      t.string  :name_field, null: false
      t.boolean :downloadable, default: false, null: false

      t.timestamps null: false
      t.integer :config, default: 0, null: false

      t.index [:name_model, :name_field, :config], unique: true
    end
  end
end
