class AddNewsletterSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscription_to_website_newsletter, :boolean, default: false
  end
end
