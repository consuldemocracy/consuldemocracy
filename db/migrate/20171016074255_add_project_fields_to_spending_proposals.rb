class AddProjectFieldsToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :project_content, :text
    add_column :spending_proposals, :project_phase, :string
  end
end
