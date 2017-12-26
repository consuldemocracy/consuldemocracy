class AddHiddenAtToRelatedContents < ActiveRecord::Migration
  def change
    add_column :related_contents, :hidden_at, :datetime
    add_index :related_contents, :hidden_at
  end
end
