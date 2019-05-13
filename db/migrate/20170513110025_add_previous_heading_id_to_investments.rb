class AddPreviousHeadingIdToInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :previous_heading_id, :integer
  end
end
