class SetOrganizationNameLimit < ActiveRecord::Migration
  def up
    execute "ALTER TABLE organizations ALTER COLUMN name TYPE VARCHAR(60) USING SUBSTR(name, 1, 60)"
    change_column :organizations, :name, :string, limit: 60
  end

  def down
    change_column :organizations, :name, :string, limit: nil
  end
end
