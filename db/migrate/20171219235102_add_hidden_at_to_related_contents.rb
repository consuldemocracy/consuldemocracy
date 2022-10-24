class AddHiddenAtToRelatedContents < ActiveRecord::Migration[4.2]
  def change
    add_column :related_contents, :hidden_at, :datetime
    add_index :related_contents, :hidden_at
  end
end
