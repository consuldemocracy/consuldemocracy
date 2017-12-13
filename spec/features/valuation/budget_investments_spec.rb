require 'rails_helper'

feature 'Valuation budget investments' do

  background do
    @valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    login_as(@valuator.user)
    @budget = create(:budget, :valuating)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.budgets'] = nil
    expect{ visit valuation_budget_budget_investments_path(create(:budget)) }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting['feature.budgets'] = true
  end

  scenario 'Display link to valuation section' do
    Setting['feature.budgets'] = true
    visit root_path
    expect(page).to have_link "Valuation", href: valuation_root_path
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

  feature 'Show' do
    scenario 'visible for assigned valuators' do
      administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
      valuator2 = create(:valuator, user: create(:user, username: 'Rick', email: 'rick@valuators.org'))
      investment = create(:budget_investment,
                           budget: @budget,
                           price: 1234,
                           feasibility: 'unfeasible',
                           unfeasibility_explanation: 'It is impossible',
                           administrator: administrator)
      investment.valuators << [@valuator, valuator2]

      visit valuation_budget_budget_investments_path(@budget)

      click_link investment.title

      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)
      expect(page).to have_content('1234')
      expect(page).to have_content('Unfeasible')
      expect(page).to have_content('It is impossible')
      expect(page).to have_content('Ana (ana@admins.org)')

      within('#assigned_valuators') do
        expect(page).to have_content('Rachel (rachel@valuators.org)')
        expect(page).to have_content('Rick (rick@valuators.org)')
      end
    end

    scenario 'visible for admins' do
      logout
      login_as create(:administrator).user

      administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
      valuator2 = create(:valuator, user: create(:user, username: 'Rick', email: 'rick@valuators.org'))
      investment = create(:budget_investment,
                           budget: @budget,
                           price: 1234,
                           feasibility: 'unfeasible',
                           unfeasibility_explanation: 'It is impossible',
                           administrator: administrator)
      investment.valuators << [@valuator, valuator2]

      visit valuation_budget_budget_investment_path(@budget, investment)

      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)
      expect(page).to have_content('1234')
      expect(page).to have_content('Unfeasible')
      expect(page).to have_content('It is impossible')
      expect(page).to have_content('Ana (ana@admins.org)')

      within('#assigned_valuators') do
        expect(page).to have_content('Rachel (rachel@valuators.org)')
        expect(page).to have_content('Rick (rick@valuators.org)')
      end
    end

    scenario 'not visible for not assigned valuators' do
      logout
      login_as create(:valuator).user

      valuator2 = create(:valuator, user: create(:user, username: 'Rick', email: 'rick@valuators.org'))
      investment = create(:budget_investment,
                           budget: @budget,
                           price: 1234,
                           feasibility: 'unfeasible',
                           unfeasibility_explanation: 'It is impossible',
                           administrator: create(:administrator))
      investment.valuators << [@valuator, valuator2]

      expect { visit valuation_budget_budget_investment_path(@budget, investment) }.to raise_error "Not Found"
    end

  end

  feature 'Valuate' do
    background do
      @investment = create(:budget_investment,
                            budget: @budget,
                            price: nil,
                            administrator: create(:administrator))
      @investment.valuators << @valuator
    end

    scenario 'Dossier empty by default' do
      visit valuation_budget_budget_investments_path(@budget)
      click_link @investment.title

      within('#price') { expect(page).to have_content('Undefined') }
      within('#price_first_year') { expect(page).to have_content('Undefined') }
      within('#duration') { expect(page).to have_content('Undefined') }
      within('#feasibility') { expect(page).to have_content('Undecided') }
      expect(page).to_not have_content('Valuation finished')
      expect(page).to_not have_content('Internal comments')
    end

    scenario 'Edit dossier' do
      visit valuation_budget_budget_investments_path(@budget)
      within("#budget_investment_#{@investment.id}") do
        click_link "Edit dossier"
      end

      fill_in 'budget_investment_price', with: '12345'
      fill_in 'budget_investment_price_first_year', with: '9876'
      fill_in 'budget_investment_price_explanation', with: 'Very cheap idea'
      choose  'budget_investment_feasibility_feasible'
      fill_in 'budget_investment_duration', with: '19 months'
      fill_in 'budget_investment_internal_comments', with: 'Should be double checked by the urbanism area'
      click_button 'Save changes'

      expect(page).to have_content "Dossier updated"

      visit valuation_budget_budget_investments_path(@budget)
      click_link @investment.title

      within('#price') { expect(page).to have_content('12345') }
      within('#price_first_year') { expect(page).to have_content('9876') }
      expect(page).to have_content('Very cheap idea')
      within('#duration') { expect(page).to have_content('19 months') }
      within('#feasibility') { expect(page).to have_content('Feasible') }
      expect(page).to_not have_content('Valuation finished')
      expect(page).to have_content('Internal comments')
      expect(page).to have_content('Should be double checked by the urbanism area')
    end

    scenario 'Feasibility can be marked as pending' do
      visit valuation_budget_budget_investment_path(@budget, @investment)
      click_link 'Edit dossier'

      expect(find("#budget_investment_feasibility_undecided")).to be_checked
      choose 'budget_investment_feasibility_feasible'
      click_button 'Save changes'

      visit edit_valuation_budget_budget_investment_path(@budget, @investment)

      expect(find("#budget_investment_feasibility_undecided")).to_not be_checked
      expect(find("#budget_investment_feasibility_feasible")).to be_checked

      choose 'budget_investment_feasibility_undecided'
      click_button 'Save changes'

      visit edit_valuation_budget_budget_investment_path(@budget, @investment)
      expect(find("#budget_investment_feasibility_undecided")).to be_checked
    end

    scenario 'Feasibility selection makes proper fields visible', :js do
      feasible_fields = ['Price (€)', 'Cost during the first year (€)', 'Price explanation', 'Time scope']
      unfeasible_fields = ['Feasibility explanation']
      any_feasibility_fields = ['Valuation finished', 'Internal comments']
      undecided_fields = feasible_fields + unfeasible_fields + any_feasibility_fields

      visit edit_valuation_budget_budget_investment_path(@budget, @investment)

      expect(find("#budget_investment_feasibility_undecided")).to be_checked

      undecided_fields.each do |field|
        expect(page).to have_content(field)
      end

      choose 'budget_investment_feasibility_feasible'

      unfeasible_fields.each do |field|
        expect(page).to_not have_content(field)
      end

      (feasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      choose 'budget_investment_feasibility_unfeasible'

      feasible_fields.each do |field|
        expect(page).to_not have_content(field)
      end

      (unfeasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      click_button 'Save changes'

      visit edit_valuation_budget_budget_investment_path(@budget, @investment)

      expect(find("#budget_investment_feasibility_unfeasible")).to be_checked
      feasible_fields.each do |field|
        expect(page).to_not have_content(field)
      end

      (unfeasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      choose 'budget_investment_feasibility_undecided'

      undecided_fields.each do |field|
        expect(page).to have_content(field)
      end
    end

    scenario 'Finish valuation' do
      visit valuation_budget_budget_investment_path(@budget, @investment)
      click_link 'Edit dossier'

      check 'budget_investment_valuation_finished'
      click_button 'Save changes'

      visit valuation_budget_budget_investments_path(@budget)
      expect(page).to_not have_content @investment.title
      click_link 'Valuation finished'

      expect(page).to have_content @investment.title
      click_link @investment.title
      expect(page).to have_content('Valuation finished')
    end

    scenario 'Validates price formats' do
      visit valuation_budget_budget_investments_path(@budget)
      within("#budget_investment_#{@investment.id}") do
        click_link "Edit dossier"
      end

      fill_in 'budget_investment_price', with: '12345,98'
      fill_in 'budget_investment_price_first_year', with: '9876.6'
      click_button 'Save changes'

      expect(page).to have_content('2 errors')
      expect(page).to have_content('Only integer numbers', count: 2)
    end
  end
end
