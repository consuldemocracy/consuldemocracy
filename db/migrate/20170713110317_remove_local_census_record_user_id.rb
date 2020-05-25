class RemoveLocalCensusRecordUserId < ActiveRecord::Migration[4.2]
  def change
    remove_column :local_census_records, :user_id
  end
end
