class AddResponsibleNameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :responsible_name, :string, limit: 60
  end
end
