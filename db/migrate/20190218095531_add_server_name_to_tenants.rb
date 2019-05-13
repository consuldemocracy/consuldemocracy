class AddServerNameToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :server_name, :string
    add_column :tenants, :twitter_key, :string
    add_column :tenants, :twitter_secret, :string
    add_column :tenants, :facebook_key, :string
    add_column :tenants, :facebook_secret, :string
  end
end
