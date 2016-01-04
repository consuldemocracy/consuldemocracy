require 'rails_helper'

feature 'Spending proposals' do

  scenario 'Index' do
    visit spending_proposals_path

    expect(page).to have_link('Create spending proposal', href: new_spending_proposal_path)
  end

end
