class DeletesHeadingIdFromBallot < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_ballots, :heading_id, :integer, index: true
  end
end
