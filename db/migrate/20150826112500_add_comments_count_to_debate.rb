class AddCommentsCountToDebate < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :comments_count, :integer, default: 0
  end
end
