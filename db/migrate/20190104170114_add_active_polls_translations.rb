class AddActivePollsTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :active_poll_translations do |t|
      t.integer :active_poll_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text "description"

      t.index :active_poll_id
      t.index :locale
    end
  end
end
