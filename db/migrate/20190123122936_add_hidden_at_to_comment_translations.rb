class AddHiddenAtToCommentTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :comment_translations, :hidden_at, :datetime
    add_index :comment_translations, :hidden_at
  end
end
