class AddBallotLineCountToInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :ballot_lines_count, :integer, default: 0
  end
end
