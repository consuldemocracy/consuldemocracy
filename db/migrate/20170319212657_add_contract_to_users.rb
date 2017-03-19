class AddContractToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contract, :integer
  end
end
