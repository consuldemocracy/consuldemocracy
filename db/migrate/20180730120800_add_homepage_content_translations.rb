class AddHomepageContentTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :widget_card_translations do |t|
      t.integer :widget_card_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :label
      t.string :title
      t.text :description
      t.string :link_text

      t.index :locale
      t.index :widget_card_id
    end
  end
end
