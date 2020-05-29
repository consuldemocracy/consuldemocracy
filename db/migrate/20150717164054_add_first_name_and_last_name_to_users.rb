class AddFirstNameAndLastNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
