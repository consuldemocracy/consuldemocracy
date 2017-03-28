require 'rails_helper'

feature 'Recommendations' do

  scenario "Create" do
    investment = create(:budget_investment)

    user = create(:user)
    login_as(user)

    visit root_path
    click_link "Delegation"

    fill_in "recommendation_investment_id", with: investment.id
    click_button "Add to my list"

    expect(page).to have_content "Investment project added to the list"
    expect(page).to have_link(investment.title, href: budget_investment_path(investment.budget, investment))
  end

  scenario "Create (errors)" do
    investment = create(:budget_investment)

    user = create(:user)
    login_as(user)

    visit root_path
    click_link "Delegation"

    fill_in "recommendation_investment_id", with: 9999
    click_button "Add to my list"

    expect(page).to have_content "Invalid ID"
    expect(page).to_not have_content investment.title
  end

  scenario "Index" do
    user1 = create(:user)
    user2 = create(:user)

    heading = create(:budget_heading)

    investment1 = create(:budget_investment, heading: heading)
    investment2 = create(:budget_investment, heading: heading)
    investment3 = create(:budget_investment, heading: heading)

    recommendation1 = create(:budget_recommendation, user: user1, investment: investment1, budget: heading.budget)
    recommendation2 = create(:budget_recommendation, user: user1, investment: investment2, budget: heading.budget)
    recommendation3 = create(:budget_recommendation, user: user2, investment: investment3, budget: heading.budget)

    login_as(user2)
    visit user_path(user1)
    click_link "List of recommended investments projects"

    expect(page).to have_content "Investment projects recommended by: #{user1.username}"

    expect(page).to have_content recommendation1.investment.title
    expect(page).to have_content recommendation2.investment.title

    expect(page).to_not have_content recommendation3.investment.title
  end

  scenario "Support another person's recommendation", :js do
    user1 = create(:user)
    user2 = create(:user, :level_two)

    investment = create(:budget_investment)
    create(:budget_recommendation, investment: investment, user: user1)
    investment.budget.update(phase: 'selecting')

    login_as(user2)
    visit user_path(user1)

    click_link "List of recommended investments projects"

    within('.supports') do
      find('.in-favor a').click

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this. Share it!"
    end
  end

  scenario "Destroy" do
    investment = create(:budget_investment)
    user = create(:user)
    create(:budget_recommendation, investment: investment, user: user)

    login_as(user)

    visit root_path
    click_link "Delegation"

    expect(page).to have_content investment.title
    click_link "Delete from my list"

    expect(page).to have_content "Investment project removed from the list"
    expect(page).to_not have_content investment.title
  end

end