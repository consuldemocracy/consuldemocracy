class AddOrganizationRejectedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organization_rejected_at, :datetime
  end
end
