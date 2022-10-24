class AddHiddenAtToLegislationProcessTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_process_translations, :hidden_at, :datetime
    add_index :legislation_process_translations, :hidden_at
  end
end
