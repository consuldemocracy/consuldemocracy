class SetOrganizationNameLimit < ActiveRecord::Migration
  def change
    change_column :organizations, :name, :string, limit: 60
  end
end
