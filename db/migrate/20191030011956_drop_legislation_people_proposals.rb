class DropLegislationPeopleProposals < ActiveRecord::Migration[5.0]
  def up
    drop_table :legislation_people_proposals
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
