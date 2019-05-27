class AddEraseReasonToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :erase_reason, :string
  end
end
