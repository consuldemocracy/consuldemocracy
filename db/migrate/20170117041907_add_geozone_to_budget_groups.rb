class AddGeozoneToBudgetGroups < ActiveRecord::Migration
  def change
    add_column :budget_groups, :geozone_id, :integer, null: nil
  end
end
