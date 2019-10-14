class AddConfirmedHideAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmed_hide_at, :datetime
  end
end
