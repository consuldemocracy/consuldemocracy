class AddTimestampsToPolls < ActiveRecord::Migration
  def change
    add_timestamps :polls, null: true
  end
end
