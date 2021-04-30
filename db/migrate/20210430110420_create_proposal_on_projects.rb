class CreateProposalOnProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :proposal_on_projects do |t|
      t.references :project, foreign_key: true
      t.references :proposal, foreign_key: true

      t.timestamps
    end
  end
end
