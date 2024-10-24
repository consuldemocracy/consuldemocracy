class CreateBudgets < ActiveRecord::Migration[4.2]
  def change
    create_table :budgets do |t|
      t.string "name", limit: 30
      t.text "description"
      t.string "currency_symbol", limit: 10

      t.string "phase", default: "on_hold", limit: 15
      t.boolean "valuating", default: false

      t.timestamps null: false
    end
  end
end
