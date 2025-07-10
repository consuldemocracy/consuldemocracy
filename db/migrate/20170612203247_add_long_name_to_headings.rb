class AddLongNameToHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :long_name, :string, limit: 1000
  end
end
