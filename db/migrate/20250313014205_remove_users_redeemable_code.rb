class RemoveUsersRedeemableCode < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :redeemable_code, :string
  end
end
