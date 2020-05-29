class AddHeadingIdToBudgetBallot < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_ballots, :heading_id, :integer
    add_index :budget_ballots, :heading_id
  end
end
