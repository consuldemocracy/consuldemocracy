class AddCommentsTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :comment_translations do |t|
      t.integer :comment_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text :body

      t.index :comment_id
      t.index :locale
    end
  end
end
