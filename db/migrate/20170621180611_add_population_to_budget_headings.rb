class AddPopulationToBudgetHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :population, :integer, default: nil
  end
end
