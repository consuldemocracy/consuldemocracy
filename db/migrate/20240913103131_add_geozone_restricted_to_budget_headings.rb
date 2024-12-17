class AddGeozoneRestrictedToBudgetHeadings < ActiveRecord::Migration[6.1]
  def change
    add_column :budget_headings, :geozone_restricted, :boolean, default:false
  end
end
