class AddBallotedHeadingIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :balloted_heading_id, :integer, default: nil
  end
end
