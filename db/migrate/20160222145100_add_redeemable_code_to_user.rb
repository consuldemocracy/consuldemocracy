class AddRedeemableCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :redeemable_code, :string
  end
end
