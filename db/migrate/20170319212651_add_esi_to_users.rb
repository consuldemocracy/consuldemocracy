class AddEsiToUsers < ActiveRecord::Migration
  def change
    add_column :users, :esi, :integer
  end
end
