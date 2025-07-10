class AddCommentsCountToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :comments_count, :integer, default: 0
    add_column :polls, :author_id, :integer
    add_column :polls, :hidden_at, :datetime
  end
end
