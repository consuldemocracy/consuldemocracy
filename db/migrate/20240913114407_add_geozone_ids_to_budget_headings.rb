class AddGeozoneIdsToBudgetHeadings < ActiveRecord::Migration[6.1]
  def change
    add_column :budget_headings, :geozone_ids, :integer, array: true, default: []
  end
end
