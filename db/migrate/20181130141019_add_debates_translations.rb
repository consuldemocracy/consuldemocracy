class AddDebatesTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :debate_translations do |t|
      t.integer :debate_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :debate_id
      t.index :locale
    end
  end
end
