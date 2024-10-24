class RemoveGeozoneIdFromBudgetHeadings < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_headings, :geozone_id, :integer
  end
end
