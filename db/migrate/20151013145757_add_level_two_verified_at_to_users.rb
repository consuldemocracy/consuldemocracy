class AddLevelTwoVerifiedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :level_two_verified_at, :datetime
  end
end
