class AddHiddenAtToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :hidden_at, :datetime
  end
end
