class CreateBudgetReclassifiedVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_reclassified_votes do |t|
      t.integer :user_id
      t.integer :investment_id
      t.string :reason, default: nil

      t.timestamps null: false
    end
  end
end
