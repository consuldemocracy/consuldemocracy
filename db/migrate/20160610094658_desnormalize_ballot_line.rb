class DesnormalizeBallotLine < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_ballot_lines, :budget_id, :integer
    add_column :budget_ballot_lines, :group_id, :integer
    add_column :budget_ballot_lines, :heading_id, :integer
  end
end
