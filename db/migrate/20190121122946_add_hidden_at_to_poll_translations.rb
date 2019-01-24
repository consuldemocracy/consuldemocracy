class AddHiddenAtToPollTranslations < ActiveRecord::Migration
  def change
    add_column :poll_translations, :hidden_at, :datetime
    add_index :poll_translations, :hidden_at
  end
end
