class RemoveChildrenCountFromComments < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :children_count, :integer, default: 0
  end
end
