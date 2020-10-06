class CreateSiteCustomizationImages < ActiveRecord::Migration[4.2]
  def change
    create_table :site_customization_images do |t|
      t.string :name, null: false
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps null: false
    end

    add_index :site_customization_images, :name, unique: true
  end
end
