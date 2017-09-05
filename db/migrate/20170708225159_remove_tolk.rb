class RemoveTolk < ActiveRecord::Migration
  def change
    remove_index :tolk_translations, column: [:phrase_id, :locale_id]
    remove_index :tolk_locales, column: :name

    drop_table :tolk_translations
    drop_table :tolk_phrases
    drop_table :tolk_locales
  end
end
