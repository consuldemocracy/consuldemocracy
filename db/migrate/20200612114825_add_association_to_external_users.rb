class AddAssociationToExternalUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :external_users, :association, :boolean
  end
end
