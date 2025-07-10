class AddRedeemableCodeToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :redeemable_code, :string
  end
end
