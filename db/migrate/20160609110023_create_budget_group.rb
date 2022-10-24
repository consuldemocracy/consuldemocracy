class CreateBudgetGroup < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_groups do |t|
      t.references :budget
      t.string     :name, limit: 50
    end

    add_index :budget_groups, :budget_id
  end
end
