class AddCommentsCountToDebate < ActiveRecord::Migration
  def change
    add_column :debates, :comments_count, :integer, default: 0
  end
end
