class RemoveGeozoneIdFromBudgetHeadings < ActiveRecord::Migration
  def change
    remove_column :budget_headings, :geozone_id
  end
end
