class AddSubscriptionsTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscriptions_token, :string
  end
end
