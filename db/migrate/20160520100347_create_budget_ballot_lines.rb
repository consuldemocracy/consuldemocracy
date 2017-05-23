class CreateBudgetBallotLines < ActiveRecord::Migration
  def change
    create_table :budget_ballot_lines do |t|
      t.integer :ballot_id, index: true
      t.integer :investment_id, index: true

      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
