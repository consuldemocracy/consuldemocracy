require 'rails_helper'

feature 'Guide the user to create the correct resource' do

  let(:user) { create(:user, :verified)}
  let!(:budget) { create(:budget, :accepting) }

  background do
    Setting['feature.guides'] = true
  end

  after do
    Setting['feature.guides'] = nil
  end

  context "Proposals" do
    scenario "Proposal creation" do
      login_as(user)
      visit proposals_path

      click_link "Create a proposal"
      find('.guide-proposal-link').click

      expect(page).to have_current_path(new_proposal_path)
    end

    scenario "Proposal creation when Budget is not accepting" do
      budget.update_attribute(:phase, :reviewing)
      login_as(user)
      visit proposals_path

      click_link "Create a proposal"

      expect(page).to have_current_path(new_proposal_path)
    end
  end

  scenario "Budget Investment not show guides" do
    login_as(user)
    visit budgets_path

    click_link "Create a budget investment"

    expect(page).to have_current_path(new_budget_investment_path(budget))
  end

  scenario "Feature deactivated" do
    Setting['feature.guides'] = nil

    login_as(user)

    visit proposals_path
    click_link "Create a proposal"

    expect(page).not_to have_link "I want to create a proposal"
    expect(page).to have_current_path(new_proposal_path)

    visit budgets_path
    click_link "Create a budget investment"

    expect(page).not_to have_link "I want to create a new budget investment"
    expect(page).to have_current_path(new_budget_investment_path(budget))
  end

end
