class DeletesHeadingIdFromBallot < ActiveRecord::Migration
  def change
    remove_column :budget_ballots, :heading_id
  end
end
