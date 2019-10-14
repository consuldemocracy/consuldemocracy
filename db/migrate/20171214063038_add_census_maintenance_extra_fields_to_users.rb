class AddCensusMaintenanceExtraFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :census_removed_at, :datetime
  end
end
