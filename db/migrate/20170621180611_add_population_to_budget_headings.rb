class AddPopulationToBudgetHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :population, :integer, default: 0
  end
end
