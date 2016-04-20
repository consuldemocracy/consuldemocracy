class AddGenreAndDobToUsers < ActiveRecord::Migration
  def change
    add_column :users, :genre, :string, index: true, limit: 10
    add_column :users, :date_of_birth, :datetime, index: true
  end
end
