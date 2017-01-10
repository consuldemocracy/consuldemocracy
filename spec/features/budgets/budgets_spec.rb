require 'rails_helper'

feature 'Budgets' do

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    visit budgets_path
    budgets.each {|budget| expect(page).to have_link(budget.name)}
  end

  scenario 'Show' do
    budget = create(:budget)
    group1 = create(:budget_group, budget: budget)
    group2 = create(:budget_group, budget: budget)

    visit budget_path(budget)

    budget.groups.each {|group| expect(page).to have_link(group.name)}
  end
end