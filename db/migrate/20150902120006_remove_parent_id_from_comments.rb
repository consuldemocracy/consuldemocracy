class RemoveParentIdFromComments < ActiveRecord::Migration
  def change
    Comment.build_ancestry_from_parent_ids! rescue nil

    remove_column :comments, :parent_id, :integer
    remove_column :comments, :lft, :integer
    remove_column :comments, :rgt, :integer
  end
end
