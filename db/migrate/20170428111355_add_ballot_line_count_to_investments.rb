class AddBallotLineCountToInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :ballot_lines_count, :integer, default: 0
  end
end
