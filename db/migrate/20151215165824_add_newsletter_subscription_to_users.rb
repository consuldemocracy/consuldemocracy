class AddNewsletterSubscriptionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :newsletter, :boolean, default: false
  end
end
