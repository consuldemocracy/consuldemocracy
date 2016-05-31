require 'rails_helper'

feature 'Budgets' do

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    visit budgets_path
    budgets.each {|budget| expect(page).to have_link(budget.name)}
  end

  scenario 'Show' do
    budget = create(:budget)
    heading = create(:budget_heading, budget: budget)
    visit budget_path(budget)
    expect(page).to have_content(budget.name)
    expect(page).to have_content(heading.name)
  end
end
