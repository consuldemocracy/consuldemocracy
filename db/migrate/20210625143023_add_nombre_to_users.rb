class AddNombreToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :apellidos, :string
    add_column :users, :nombres, :string
  end
end
