class AddPostalCodeToUsers < ActiveRecord::Migration
  def change
	add_column :users, :postal_code, "varchar(10)"
  end
end