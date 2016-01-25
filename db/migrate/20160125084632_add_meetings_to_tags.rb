class AddMeetingsToTags < ActiveRecord::Migration
  def change
    add_column :tags, :meetings_count, :integer, default: 0
    add_index :tags, :meetings_count
  end
end
