class AddSchemaTypeToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :schema_type, :integer, null: false, default: 0
  end
end
