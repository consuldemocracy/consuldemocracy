class CreateTinymceAssets < ActiveRecord::Migration
  def change
    create_table :tinymce_assets do |t|
      t.string :file
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at

      t.timestamps null: false
    end
  end
end