class AddConfirmedHideAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :confirmed_hide_at, :datetime
  end
end
