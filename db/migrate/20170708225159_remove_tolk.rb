class RemoveTolk < ActiveRecord::Migration[4.2]
  def up
    remove_index :tolk_translations, column: [:phrase_id, :locale_id]
    remove_index :tolk_locales, column: :name

    drop_table :tolk_translations
    drop_table :tolk_phrases
    drop_table :tolk_locales
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
