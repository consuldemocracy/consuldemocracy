class AddHiddenAtToPollTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_translations, :hidden_at, :datetime
    add_index :poll_translations, :hidden_at
  end
end
