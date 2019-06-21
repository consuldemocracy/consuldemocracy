class RemoveQuestionAndExternalUrlFromLegislationProposals < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_proposals, :question, :string
    remove_column :legislation_proposals, :external_url, :string
  end
end
