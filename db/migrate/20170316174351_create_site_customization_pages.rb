class CreateSiteCustomizationPages < ActiveRecord::Migration
  def change
    create_table :site_customization_pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :subtitle
      t.text :content
      t.boolean :more_info_flag
      t.boolean :print_content_flag
      t.string :status, default: 'draft'

      t.timestamps null: false
    end
  end
end
