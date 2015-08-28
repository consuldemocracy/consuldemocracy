class AddResidenceVerifiedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :residence_verified_at, :datetime
  end
end
