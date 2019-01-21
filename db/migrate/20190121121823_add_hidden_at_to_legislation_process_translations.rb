class AddHiddenAtToLegislationProcessTranslations < ActiveRecord::Migration
  def change
    add_column :legislation_process_translations, :hidden_at, :datetime
    add_index :legislation_process_translations, :hidden_at
  end
end
