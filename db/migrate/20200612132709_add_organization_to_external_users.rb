class AddOrganizationToExternalUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :external_users, :organization, :boolean
  end
end
