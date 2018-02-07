require 'rails_helper'

describe 'Guide the user to create the correct resource' do

  let(:user) { create(:user, :verified)}
  let!(:budget) { create(:budget, :accepting) }

  before do
    Setting['feature.guides'] = true
  end

  after do
    Setting['feature.guides'] = nil
  end

  it "Proposal" do
    login_as(user)
    visit proposals_path

    click_link "Create a proposal"
    click_link "I want to create a proposal"

    expect(page).to have_current_path(new_proposal_path)
  end

  it "Budget Investment" do
    login_as(user)
    visit budgets_path

    click_link "Create a budget investment"
    click_link "I want to create a budget investment"

    expect(page).to have_current_path(new_budget_investment_path(budget))
  end

  it "Feature deactivated" do
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