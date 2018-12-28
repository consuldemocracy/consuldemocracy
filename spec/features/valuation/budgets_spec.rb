require 'rails_helper'

feature 'Valuation budgets' do

  let!(:valuator) do
    create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
  end

  background do
    login_as(valuator.user)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.budgets'] = nil
    expect{ visit valuation_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting['feature.budgets'] = true
  end

  context 'Index' do

    scenario 'Displaying budgets' do
      budget = create(:budget, name: 'Current Budget')
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      valuator_group = create(:valuator_group, valuators: [valuator])
      individual_access = create(:budget_investment, visible_to_valuators: true, budget: budget,
                                                     heading: heading, group: group,
                                                     valuators: [valuator])
      indiv_and_group_access = create(:budget_investment, visible_to_valuators: true,
                                                          budget: budget, heading: heading,
                                                          group: group, valuators: [valuator],
                                                          valuator_groups: [valuator_group])
      group_access = create(:budget_investment, visible_to_valuators: true, budget: budget,
                                                heading: heading, group: group,
                                                valuator_groups: [valuator_group])
      access_but_finished = create(:budget_investment, :finished, visible_to_valuators: true,
                                                                  budget: budget, heading: heading,
                                                                  group: group,
                                                                  valuators: [valuator],
                                                                  valuator_groups: [valuator_group])
      access_but_not_visible = create(:budget_investment, visible_to_valuators: false,
                                                          budget: budget, heading: heading,
                                                          group: group,
                                                          valuators: [valuator],
                                                          valuator_groups: [valuator_group])
      no_access = create(:budget_investment, visible_to_valuators: true, budget: budget,
                                             heading: heading, group: group)

      visit valuation_budgets_path

      expect(page).to have_content('Current Budget')
      within("#budget_#{budget.id}") do
        expect(page).to have_content('3')
      end
    end

    scenario 'Filters by phase' do
      budget1 = create(:budget, :finished)
      budget2 = create(:budget, :finished)
      budget3 = create(:budget, :accepting)

      visit valuation_budgets_path

      expect(page).not_to have_content(budget1.name)
      expect(page).not_to have_content(budget2.name)
      expect(page).to have_content(budget3.name)
    end

    scenario "With no budgets" do
      visit valuation_budgets_path

      expect(page).to have_content "There are no budgets"
    end
  end

end
