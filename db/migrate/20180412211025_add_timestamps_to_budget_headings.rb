class AddTimestampsToBudgetHeadings < ActiveRecord::Migration
  def change
    add_timestamps :budget_headings, null: true
  end
end
