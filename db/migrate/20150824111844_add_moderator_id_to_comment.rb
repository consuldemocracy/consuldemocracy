class AddModeratorIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :moderator_id, :integer, default: nil
  end
end
