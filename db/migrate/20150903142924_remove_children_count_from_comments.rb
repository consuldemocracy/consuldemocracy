class RemoveChildrenCountFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :children_count, :integer, default: 0
  end
end
