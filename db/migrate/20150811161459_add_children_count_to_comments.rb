class AddChildrenCountToComments < ActiveRecord::Migration[4.2]
  def up
    add_column :comments, :children_count, :integer, default: 0
  end

  def down
    remove_column :comments, :children_count
  end
end
