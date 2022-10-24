class AddResidenceVerifiedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :residence_verified_at, :datetime
  end
end
