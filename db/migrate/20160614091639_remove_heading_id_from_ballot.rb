class RemoveHeadingIdFromBallot < ActiveRecord::Migration
  def change
    remove_column :budget_ballots, :heading_id, :integer
  end
end
