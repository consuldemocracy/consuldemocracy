class AddBallotedHeadingIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :balloted_heading_id, :integer, default: nil
  end
end
