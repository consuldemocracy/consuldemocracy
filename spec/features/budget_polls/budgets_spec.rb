require 'rails_helper'

feature 'Admin Budgets' do

  background do
    admin = create(:administrator).user
    login_as(admin)
  end

  scenario 'Admin ballots link appears if budget has a poll associated' do
    budget = create(:budget)
    create(:poll, budget: budget)

    visit admin_budgets_path

    within "#budget_#{budget.id}" do
      expect(page).to have_link("Admin ballots")
    end
  end

end