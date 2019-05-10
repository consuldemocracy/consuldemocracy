class AddLegislationProcessesCountToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, "legislation/processes_count", :integer, default: 0
    add_index :tags, :"legislation/processes_count"
  end
end
