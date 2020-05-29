class CreateTolkTables < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tolk_locales do |t|
      t.string   :name
      t.timestamps
    end

    add_index :tolk_locales, :name, unique: true

    create_table :tolk_phrases do |t|
      t.text     :key
      t.timestamps
    end

    create_table :tolk_translations do |t|
      t.integer  :phrase_id
      t.integer  :locale_id
      t.text     :text
      t.text     :previous_text
      t.boolean  :primary_updated, default: false
      t.timestamps
    end

    add_index :tolk_translations, [:phrase_id, :locale_id], unique: true
  end

  def self.down
    remove_index :tolk_translations, column: [:phrase_id, :locale_id]
    remove_index :tolk_locales, column: :name

    drop_table :tolk_translations
    drop_table :tolk_phrases
    drop_table :tolk_locales
  end
end
