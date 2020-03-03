class AddZipcodeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :zipcode, :string
  end
end
