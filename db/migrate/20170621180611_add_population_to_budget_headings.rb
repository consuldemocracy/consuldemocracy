class AddPopulationToBudgetHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :population, :integer, default: nil
  end
end
