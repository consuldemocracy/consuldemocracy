class AddPhoneNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string, limit: 30
  end
end
