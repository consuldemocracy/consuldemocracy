class AddExtraCountersToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :debates_count, :integer, default: 0
    add_column :tags, :proposals_count, :integer, default: 0
    add_index :tags, :debates_count
    add_index :tags, :proposals_count
  end
end
