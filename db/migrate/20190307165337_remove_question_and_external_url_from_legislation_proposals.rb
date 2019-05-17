class RemoveQuestionAndExternalUrlFromLegislationProposals < ActiveRecord::Migration
  def change
    remove_column :legislation_proposals, :question, :string
    remove_column :legislation_proposals, :external_url, :string
  end
end
