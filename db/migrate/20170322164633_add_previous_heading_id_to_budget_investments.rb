class AddPreviousHeadingIdToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :previous_heading_id, :integer, default: nil
  end
end
