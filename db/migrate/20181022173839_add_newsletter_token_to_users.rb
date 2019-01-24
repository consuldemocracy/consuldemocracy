class AddNewsletterTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newsletter_token, :string
  end
end
