class AddPublicInterestsToUser < ActiveRecord::Migration
  def change
    add_column :users, :public_interests, :boolean, default: false
  end
end
