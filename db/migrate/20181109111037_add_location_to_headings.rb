class AddLocationToHeadings < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_headings, :latitude, :text
    add_column :budget_headings, :longitude, :text
  end
end
