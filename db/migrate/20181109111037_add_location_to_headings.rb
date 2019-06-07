class AddLocationToHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :latitude, :text
    add_column :budget_headings, :longitude, :text
  end
end
