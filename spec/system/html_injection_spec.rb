require "rails_helper"

describe "HTML injection protection" do
  let(:attack_code) { "<a href='/evil'>Click me</a>" }

  scenario "debates search" do
    visit debates_path(search: attack_code)

    expect(page).to have_content "containing the term 'Click me'"
    expect(page).not_to have_link "Click me"
  end

  scenario "investments search" do
    visit budget_investments_path(budget_id: create(:budget), search: attack_code)

    expect(page).to have_content "containing the term 'Click me'"
    expect(page).not_to have_link "Click me"
  end

  scenario "proposals search" do
    visit proposals_path(search: attack_code)

    expect(page).to have_content "containing the term 'Click me'"
    expect(page).not_to have_link "Click me"
  end

  scenario "proposals search in the management area" do
    login_managed_user(create(:user, :level_two))
    login_as_manager

    visit management_proposals_path(search: attack_code)

    expect(page).to have_content "containing the term 'Click me'"
    expect(page).not_to have_link "Click me"
  end
end
