class AddOriginalHeadingIdToInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :original_heading_id, :integer
  end
end
