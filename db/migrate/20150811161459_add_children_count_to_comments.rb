class AddChildrenCountToComments < ActiveRecord::Migration
  def up
    add_column :comments, :children_count, :integer, default: 0

    Comment.find_each do |comment|
      Comment.reset_counters(comment.id, :children)
    end
  end

  def down
    remove_column :comments, :children_count
  end
end
