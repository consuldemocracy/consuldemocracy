class AddSmsTriedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sms_tries, :integer, default: 0
  end
end
