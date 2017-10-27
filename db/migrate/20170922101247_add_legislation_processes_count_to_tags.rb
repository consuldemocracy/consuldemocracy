class AddLegislationProcessesCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, "legislation/processes_count", :integer, default: 0
    add_index :tags, "legislation/processes_count"
  end
end
