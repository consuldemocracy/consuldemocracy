class AddTimestampsToBudgetHeadings < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :budget_headings, null: true
  end
end
