class AddHeadingIdToBudgetBallot < ActiveRecord::Migration
  def change
    add_column :budget_ballots, :heading_id, :integer
    add_index :budget_ballots, :heading_id
  end
end
