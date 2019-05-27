class RemoveFlaggedAsInappropiateAtFromCommentsAndDebates < ActiveRecord::Migration[4.2]
  def change
    remove_column :debates, :flagged_as_inappropiate_at
    remove_column :comments, :flagged_as_inappropiate_at
  end
end
