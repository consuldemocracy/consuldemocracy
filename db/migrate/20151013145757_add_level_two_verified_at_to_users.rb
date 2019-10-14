class AddLevelTwoVerifiedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :level_two_verified_at, :datetime
  end
end
