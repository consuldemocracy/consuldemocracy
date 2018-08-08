class AddSelectedToLegislationProposals < ActiveRecord::Migration
  def change
    add_column :legislation_proposals, :selected, :boolean
  end
end
