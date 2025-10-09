class RemoveDefaultValueInUserNotifications < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.change_default :newsletter, from: true, to: nil
      t.change_default :email_digest, from: true, to: nil
      t.change_default :email_on_direct_message, from: true, to: nil
    end
  end
end
