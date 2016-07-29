require 'rails_helper'

feature 'Admin budgets' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context 'Feature flag' do

    xscenario 'Disabled with a feature flag' do
      Setting['feature.budgets'] = nil
      expect{ visit admin_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context 'Index' do

    scenario 'Displaying budgets' do
      budget = create(:budget)
      visit admin_budgets_path

      expect(page).to have_content(budget.name)
      expect(page).to have_content(I18n.t("budget.phase.#{budget.phase}"))
    end

    scenario 'Filters by phase' do
      budget1 = create(:budget)
      budget2 = create(:budget, :accepting)
      budget3 = create(:budget, :selecting)
      budget4 = create(:budget, :balloting)
      budget5 = create(:budget, :finished)

      visit admin_budgets_path
      expect(page).to have_content(budget1.name)
      expect(page).to have_content(budget2.name)
      expect(page).to have_content(budget3.name)
      expect(page).to have_content(budget4.name)
      expect(page).to_not have_content(budget5.name)

      click_link 'Finished'
      expect(page).to_not have_content(budget1.name)
      expect(page).to_not have_content(budget2.name)
      expect(page).to_not have_content(budget3.name)
      expect(page).to_not have_content(budget4.name)
      expect(page).to have_content(budget5.name)

      click_link 'Open'
      expect(page).to have_content(budget1.name)
      expect(page).to have_content(budget2.name)
      expect(page).to have_content(budget3.name)
      expect(page).to have_content(budget4.name)
      expect(page).to_not have_content(budget5.name)
    end


    scenario 'Current filter is properly highlighted' do
      filters_links = {'open' => 'Open', 'finished' => 'Finished'}

      visit admin_budgets_path

      expect(page).to_not have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit admin_budgets_path(filter: current_filter)

        expect(page).to_not have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

  end

  context 'New' do
    scenario 'Create budget' do
      visit admin_budgets_path
      click_link 'Create new'

      fill_in 'budget_name', with: 'M30 - Summer campaign'
      fill_in 'budget_description', with: 'Budgeting for summer 2017 maintenance and improvements of the road M-30'
      select 'Accepting proposals', from: 'budget[phase]'

      click_button 'Create budget'

      expect(page).to have_content 'New participatory budget created successfully!'
      expect(page).to have_content 'M30 - Summer campaign'
    end

    scenario 'Name is mandatory' do
      visit new_admin_budget_path
      click_button 'Create budget'

      expect(page).to_not have_content 'New participatory budget created successfully!'
      expect(page).to have_css("label.error", text: "Budget's name")
    end

  end
end