class AddUniqueIndexToVotes < ActiveRecord::Migration[8.0]
  def change
    add_index :votes, [:votable_id, :votable_type, :voter_id, :voter_type], unique: true
  end
end
