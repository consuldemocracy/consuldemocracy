class AddTranslatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :site_customization_page_translations do |t|
      t.integer :site_customization_page_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.string :subtitle
      t.text :content

      t.index :locale
      t.index :site_customization_page_id, name: "index_7fa0f9505738cb31a31f11fb2f4c4531fed7178b"
    end

    change_column_null :site_customization_pages, :title, from: false, to: true
  end
end
