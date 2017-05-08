require 'rails_helper'

feature 'Beta testing' do

  let!(:budget)     { create(:budget, phase: "balloting") }
  let!(:states)     { create(:budget_group, budget: budget, name: "States") }
  let!(:california) { create(:budget_heading, group: states) }
  let!(:investment) { create(:budget_investment, :selected, heading: california) }

  scenario 'Beta testing enabled', :js do
    allow_any_instance_of(Budget).to receive(:beta_testing?).and_return(true)

    user = create(:user)
    login_as(user)

    visit budget_path(budget)
    click_link "States"

    within("#budget_investment_#{investment.id}") do
      find("div.ballot").hover
      expect(page).to_not have_content 'Only verified users can vote on investments'
    end
  end

  scenario 'Beta testing disabled', :js do
    allow_any_instance_of(Budget).to receive(:beta_testing?).and_return(false)

    user = create(:user)
    login_as(user)

    visit budget_path(budget)
    click_link "States"

    within("#budget_investment_#{investment.id}") do
      find("div.ballot").hover
      expect(page).to have_content 'Only verified users can vote on investments'
    end
  end

  scenario "User not logged in", :js do
    allow_any_instance_of(Budget).to receive(:beta_testing?).and_return(true)

    visit budget_path(budget)
    click_link "States"

    within("#budget_investment_#{investment.id}") do
      find("div.ballot").hover
      expect(page).to have_content 'You must Sign in or Sign up to continue.'
    end
  end

end
