class AddLegislationProposalsCountToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, "legislation/proposals_count", :integer, default: 0
    add_index :tags, :"legislation/proposals_count"
  end
end
