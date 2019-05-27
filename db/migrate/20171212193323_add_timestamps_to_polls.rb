class AddTimestampsToPolls < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :polls, null: true
  end
end
