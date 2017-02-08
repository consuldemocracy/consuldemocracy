class AddPublishedToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :published, :boolean, default: false
  end
end
