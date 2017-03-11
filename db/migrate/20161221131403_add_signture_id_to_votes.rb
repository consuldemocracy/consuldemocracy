class AddSigntureIdToVotes < ActiveRecord::Migration
  def change
    add_reference :votes, :signature, index: true
  end
end
