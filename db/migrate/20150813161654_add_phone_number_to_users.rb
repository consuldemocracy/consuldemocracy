class AddPhoneNumberToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :phone_number, :string, limit: 30
  end
end
