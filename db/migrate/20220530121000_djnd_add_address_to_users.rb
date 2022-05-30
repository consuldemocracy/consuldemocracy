class DjndAddAddressToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :address, :text
  end
end
