class AddOrganizationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organization_name, :string, limit: 80
    add_column :users, :organization_verified_at, :datetime
    add_column :users, :phone_number, :string, limit: 30
  end
end
