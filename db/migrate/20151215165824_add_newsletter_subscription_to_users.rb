class AddNewsletterSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newsletter, :boolean, default: false
  end
end
