class CreateBudgetBallotLines < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_ballot_lines do |t|
      t.integer :ballot_id, index: true
      t.integer :investment_id, index: true

      t.timestamps null: false
    end
  end
end
