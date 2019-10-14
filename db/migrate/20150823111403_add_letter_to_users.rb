class AddLetterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :letter_requested, :boolean, default: false
    add_column :users, :letter_sent_at, :datetime
  end
end
