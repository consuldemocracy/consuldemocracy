class AddBannerTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :banner_translations do |t|
      t.integer :banner_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :banner_id
      t.index :locale
    end
  end
end
