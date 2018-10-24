class AddNewsletterTokenUsedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newsletter_token_used_at, :datetime
  end
end
