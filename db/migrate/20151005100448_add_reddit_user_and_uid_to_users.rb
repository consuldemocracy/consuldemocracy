class AddRedditUserAndUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reddit_user, :string
    add_column :users, :reddit_uid, :string
  end
end
