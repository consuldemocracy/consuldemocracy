class AddSelectedToLegislationProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_proposals, :selected, :boolean
  end
end
