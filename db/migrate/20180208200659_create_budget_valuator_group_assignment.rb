class CreateBudgetValuatorGroupAssignment < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_valuator_group_assignments do |t|
      t.integer :valuator_group_id
      t.integer :investment_id
    end
  end
end
