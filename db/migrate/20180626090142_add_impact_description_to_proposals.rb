class AddImpactDescriptionToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :impact_description, :text
  end
end
