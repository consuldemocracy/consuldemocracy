class CreateSiteCustomizationContentBlocks < ActiveRecord::Migration
  def change
    create_table :site_customization_content_blocks do |t|
      t.string :name
      t.string :locale
      t.text :body

      t.timestamps null: false
    end

    add_index :site_customization_content_blocks, [:name, :locale], unique: true
  end
end
