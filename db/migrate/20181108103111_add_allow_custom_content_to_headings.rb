class AddAllowCustomContentToHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :allow_custom_content, :boolean, default: false
  end
end
