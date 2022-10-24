class CreateI18nContentTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :i18n_contents, id: :serial do |t|
      t.string :key
    end

    create_table :i18n_content_translations do |t|
      t.integer :i18n_content_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text :value

      t.index :i18n_content_id
      t.index :locale
    end
  end
end
