class AddModeratorIdToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :moderator_id, :integer, default: nil
  end
end
