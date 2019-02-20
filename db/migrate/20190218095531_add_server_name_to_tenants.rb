class AddServerNameToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :server_name, :string
  end
end
