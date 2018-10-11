class AddWhenShowFieldsToPoll < ActiveRecord::Migration
  def up
    add_column :polls, :when_show_results, :boolean, default: false
    add_column :polls, :when_show_stats, :boolean, default: false
  end

  def down
    remove_column :polls, :when_show_results
    remove_column :polls, :when_show_stats
  end
end
