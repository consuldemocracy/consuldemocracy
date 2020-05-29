class AddContactFieldsToLegislationPeopleProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_people_proposals, :email, :string
    add_column :legislation_people_proposals, :phone, :string
    add_column :legislation_people_proposals, :twitter, :string
    add_column :legislation_people_proposals, :facebook, :string
    add_column :legislation_people_proposals, :instagram, :string
    add_column :legislation_people_proposals, :youtube, :string
    add_column :legislation_people_proposals, :website, :string
  end
end
