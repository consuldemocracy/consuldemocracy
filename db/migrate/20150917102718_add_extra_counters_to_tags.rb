class AddExtraCountersToTags < ActiveRecord::Migration
  def change
    add_column :tags, :debates_count, :integer, default: 0
    add_column :tags, :proposals_count, :integer, default: 0
    add_index :tags, :debates_count
    add_index :tags, :proposals_count
  end
end
