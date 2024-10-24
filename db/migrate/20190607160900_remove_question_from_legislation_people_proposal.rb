class RemoveQuestionFromLegislationPeopleProposal < ActiveRecord::Migration[5.0]
  def change
    remove_column :legislation_people_proposals, :question, :string
  end
end
