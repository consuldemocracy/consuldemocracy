class AddHiddenAtToDebateTranslations < ActiveRecord::Migration
  def change
    add_column :debate_translations, :hidden_at, :datetime
    add_index :debate_translations, :hidden_at
  end
end
