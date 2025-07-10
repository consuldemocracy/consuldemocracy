class AddPostalCodeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :postal_code, "varchar(10)"
  end
end
