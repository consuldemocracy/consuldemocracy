class AddSigntureIdToVotes < ActiveRecord::Migration[4.2]
  def change
    add_reference :votes, :signature, index: true
  end
end
