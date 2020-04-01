class AddShortNameToHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :short_name, :string, limit: 100
  end
end
