class DesnormalizeBallotLine < ActiveRecord::Migration
  def change
    add_column :budget_ballot_lines, :budget_id, :integer, index: true
    add_column :budget_ballot_lines, :group_id, :integer, index: true
    add_column :budget_ballot_lines, :heading_id, :integer, index: true
  end
end
