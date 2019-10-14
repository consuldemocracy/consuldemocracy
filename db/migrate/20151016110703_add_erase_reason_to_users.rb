class AddEraseReasonToUsers < ActiveRecord::Migration
  def change
    add_column :users, :erase_reason, :string
  end
end
