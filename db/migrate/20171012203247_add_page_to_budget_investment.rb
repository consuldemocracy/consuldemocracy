class AddPageToBudgetInvestment < ActiveRecord::Migration
  def change
    add_column :budget_investments, :project_content, :text
    add_column :budget_investments, :project_phase, :string
  end
end
