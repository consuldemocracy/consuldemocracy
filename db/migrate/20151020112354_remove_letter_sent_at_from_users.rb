class RemoveLetterSentAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :letter_sent_at, :datetime
  end
end
