class CommissionToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :commission, index: true, foreign_key: true
  end
end
