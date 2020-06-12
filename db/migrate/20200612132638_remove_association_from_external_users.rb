class RemoveAssociationFromExternalUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :external_users, :association, :boolean
  end
end
