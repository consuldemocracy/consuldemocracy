class AddSmsTriedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_tries, :integer, default: 0
  end
end
