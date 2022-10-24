class AddPublicInterestsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :public_interests, :boolean, default: false
  end
end
