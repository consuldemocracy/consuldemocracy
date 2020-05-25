class CreateBudgetBallots < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_ballots do |t|
      t.references :geozone
      t.references :user
      t.references :budget

      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
