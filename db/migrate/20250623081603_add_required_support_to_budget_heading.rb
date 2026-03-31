class AddRequiredSupportToBudgetHeading < ActiveRecord::Migration[7.0]
  def change
    add_column :budget_headings, :required_support, :integer
  end
end
