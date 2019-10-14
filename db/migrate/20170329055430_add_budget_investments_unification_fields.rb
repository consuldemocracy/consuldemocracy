#MKH-98 - Extra fields to allow budget investment unification
class AddBudgetInvestmentsUnificationFields < ActiveRecord::Migration
  def change

    add_column :budget_investments, :unified_with_id, :integer
    add_column  :budget_investments, :unification_reason,  :string
    add_column  :budget_investments, :unification_explanation, :text

    add_index :budget_investments, :unified_with_id
  end
end
