class RemoveLetterSentAtFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :letter_sent_at, :datetime
  end
end
