class AddLegislationProposalsCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, "legislation/proposals_count", :integer, default: 0
    add_index :tags, "legislation/proposals_count"
  end
end
