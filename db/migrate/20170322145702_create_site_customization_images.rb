class CreateSiteCustomizationImages < ActiveRecord::Migration
  def change
    create_table :site_customization_images do |t|
      t.string :name, null: false
      t.attachment :image
      t.timestamps null: false
    end

    add_index :site_customization_images, :name, unique: true
  end
end
