class AddHiddenAtToBannerTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :banner_translations, :hidden_at, :datetime
    add_index :banner_translations, :hidden_at
  end
end
