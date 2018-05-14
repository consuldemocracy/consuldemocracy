class AddIndexToNvotes < ActiveRecord::Migration
  def change
    add_index :poll_nvotes, :voter_hash
    add_index :poll_nvotes, :user_id
  end
end
