class RemoveBallotedHeadingIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :balloted_heading_id, :integer
  end
end
