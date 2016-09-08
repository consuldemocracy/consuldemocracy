require 'rails_helper'

feature 'Valuation budgets' do

  background do
    @valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    login_as(@valuator.user)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.budgets'] = nil
    expect{ visit valuation_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  context 'Index' do

    scenario 'Displaying budgets' do
      budget = create(:budget)
      visit valuation_budgets_path

      expect(page).to have_content(budget.name)
    end

    scenario 'Filters by phase' do
      budget1 = create(:budget)
      budget2 = create(:budget, :accepting)
      budget3 = create(:budget, :selecting)
      budget4 = create(:budget, :balloting)
      budget5 = create(:budget, :finished)

      visit valuation_budgets_path
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

      visit valuation_budgets_path

      expect(page).to_not have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit valuation_budgets_path(filter: current_filter)

        expect(page).to_not have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

  end

end