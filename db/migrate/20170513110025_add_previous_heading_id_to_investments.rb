class AddPreviousHeadingIdToInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :previous_heading_id, :integer
  end
end
