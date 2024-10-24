class CreateDownloadSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :download_settings do |t|
      t.string :name_model, null: false
      t.string :name_field, null: false
      t.boolean :downloadable, null: false, default: false

      t.timestamps null: false
    end

    add_index :download_settings, [:name_model, :name_field], unique: true
  end
end
