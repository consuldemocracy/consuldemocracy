class AddNvotesPollIdToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :nvotes_poll_id, :string
  end
end
