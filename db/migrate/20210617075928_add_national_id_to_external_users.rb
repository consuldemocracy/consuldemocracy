class AddNationalIdToExternalUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :external_users, :national_id, :string
  end
end
