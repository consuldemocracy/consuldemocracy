class AddAllowCustomContentToHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :allow_custom_content, :boolean, default: false
  end
end
