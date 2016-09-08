require 'rails_helper'

feature 'Valuation budget investments' do

  background do
    @valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    login_as(@valuator.user)
    @budget = create(:budget, valuating: true)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.budgets'] = nil
    expect{ visit valuation_budget_budget_investments_path(create(:budget)) }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario 'Index shows budget investments assigned to current valuator' do
    investment1 = create(:budget_investment, budget: @budget)
    investment2 = create(:budget_investment, budget: @budget)

    investment1.valuators << @valuator

    visit valuation_budget_budget_investments_path(@budget)

    expect(page).to have_content(investment1.title)
    expect(page).to_not have_content(investment2.title)
  end

  scenario 'Index shows no budget investment to admins no valuators' do
    investment1 = create(:budget_investment, budget: @budget)
    investment2 = create(:budget_investment, budget: @budget)

    investment1.valuators << @valuator

    logout
    login_as create(:administrator).user
    visit valuation_budget_budget_investments_path(@budget)

    expect(page).to_not have_content(investment1.title)
    expect(page).to_not have_content(investment2.title)
  end

  scenario 'Index orders budget investments by votes' do
    investment10  = create(:budget_investment, budget: @budget, cached_votes_up: 10)
    investment100 = create(:budget_investment, budget: @budget, cached_votes_up: 100)
    investment1   = create(:budget_investment, budget: @budget, cached_votes_up: 1)

    investment1.valuators << @valuator
    investment10.valuators << @valuator
    investment100.valuators << @valuator

    visit valuation_budget_budget_investments_path(@budget)

    expect(investment100.title).to appear_before(investment10.title)
    expect(investment10.title).to appear_before(investment1.title)
  end

  scenario 'Index shows assignments info' do
    investment1 = create(:budget_investment, budget: @budget)
    investment2 = create(:budget_investment, budget: @budget)
    investment3 = create(:budget_investment, budget: @budget)

    valuator1 = create(:valuator, user: create(:user))
    valuator2 = create(:valuator, user: create(:user))
    valuator3 = create(:valuator, user: create(:user))

    investment1.valuator_ids = [@valuator.id]
    investment2.valuator_ids = [@valuator.id, valuator1.id, valuator2.id]
    investment3.valuator_ids = [@valuator.id, valuator3.id]

    visit valuation_budget_budget_investments_path(@budget)

    within("#budget_investment_#{investment1.id}") do
      expect(page).to have_content("Rachel")
    end

    within("#budget_investment_#{investment2.id}") do
      expect(page).to have_content("3 valuators assigned")
    end

    within("#budget_investment_#{investment3.id}") do
      expect(page).to have_content("2 valuators assigned")
    end
  end

  scenario "Index filtering by heading", :js do
    group = create(:budget_group, budget: @budget)
    heading1 = create(:budget_heading, name: "District 9", group: group)
    heading2 = create(:budget_heading, name: "Down to the river", group: group)
    investment1 = create(:budget_investment, title: "Realocate visitors", heading: heading1, group: group, budget: @budget)
    investment2 = create(:budget_investment, title: "Destroy the city", heading: heading2, group: group, budget: @budget)
    investment1.valuators << @valuator
    investment2.valuators << @valuator

    visit valuation_budget_budget_investments_path(@budget)

    expect(page).to have_link("Realocate visitors")
    expect(page).to have_link("Destroy the city")


    expect(page).to have_content "All headings (2)"
    expect(page).to have_content "District 9 (1)"
    expect(page).to have_content "Down to the river (1)"

    click_link "District 9", exact: false

    expect(page).to have_link("Realocate visitors")
    expect(page).to_not have_link("Destroy the city")

    click_link "Down to the river", exact: false

    expect(page).to have_link("Destroy the city")
    expect(page).to_not have_link("Realocate visitors")

    click_link "All headings", exact: false
    expect(page).to have_link("Realocate visitors")
    expect(page).to have_link("Destroy the city")
  end

  scenario "Current filter is properly highlighted" do
    filters_links = {'valuating' => 'Under valuation',
                     'valuation_finished' => 'Valuation finished'}

    visit valuation_budget_budget_investments_path(@budget)

    expect(page).to_not have_link(filters_links.values.first)
    filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

    filters_links.each_pair do |current_filter, link|
      visit valuation_budget_budget_investments_path(@budget, filter: current_filter)

      expect(page).to_not have_link(link)

      (filters_links.keys - [current_filter]).each do |filter|
        expect(page).to have_link(filters_links[filter])
      end
    end
  end

  scenario "Index filtering by valuation status" do
    valuating = create(:budget_investment, budget: @budget, title: "Ongoing valuation")
    valuated  = create(:budget_investment, budget: @budget, title: "Old idea", valuation_finished: true)
    valuating.valuators << @valuator
    valuated.valuators << @valuator

    visit valuation_budget_budget_investments_path(@budget)

    expect(page).to have_content("Ongoing valuation")
    expect(page).to_not have_content("Old idea")

    visit valuation_budget_budget_investments_path(@budget, filter: 'valuating')

    expect(page).to have_content("Ongoing valuation")
    expect(page).to_not have_content("Old idea")

    visit valuation_budget_budget_investments_path(@budget, filter: 'valuation_finished')

    expect(page).to_not have_content("Ongoing valuation")
    expect(page).to have_content("Old idea")
  end

end