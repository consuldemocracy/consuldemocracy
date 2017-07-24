class RemoveLocalCensusRecordUserId < ActiveRecord::Migration
  def change
    remove_column :local_census_records, :user_id
  end
end
