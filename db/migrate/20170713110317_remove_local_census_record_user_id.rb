class RemoveLocalCensusRecordUserId < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :local_census_records, :users
    remove_column :local_census_records, :user_id, :integer
  end
end
