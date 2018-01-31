require 'rails_helper'

feature 'Admin budget investments' do

  let(:budget) { create(:budget) }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do

    background do
      Setting['feature.budgets'] = nil
    end

    after do
      Setting['feature.budgets'] = true
    end

    scenario 'Disabled with a feature flag' do
      expect{ visit admin_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario 'Displaying investments' do
      budget_investment = create(:budget_investment, budget: budget, cached_votes_up: 77)
      visit admin_budget_budget_investments_path(budget_id: budget.id)
      expect(page).to have_content(budget_investment.title)
      expect(page).to have_content(budget_investment.heading.name)
      expect(page).to have_content(budget_investment.id)
      expect(page).to have_content(budget_investment.total_votes)
    end

    scenario 'If budget is finished do not show "Selected" button' do
      finished_budget = create(:budget, :finished)
      budget_investment = create(:budget_investment, budget: finished_budget, cached_votes_up: 77)

      visit admin_budget_budget_investments_path(budget_id: finished_budget.id)

      within("#budget_investment_#{budget_investment.id}") do
        expect(page).to have_content(budget_investment.title)
        expect(page).to have_content(budget_investment.heading.name)
        expect(page).to have_content(budget_investment.id)
        expect(page).to have_content(budget_investment.total_votes)
        expect(page).not_to have_link("Selected")
      end
    end

    scenario 'Displaying assignments info' do
      budget_investment1 = create(:budget_investment, budget: budget)
      budget_investment2 = create(:budget_investment, budget: budget)
      budget_investment3 = create(:budget_investment, budget: budget)

      valuator1 = create(:valuator, user: create(:user, username: 'Olga'), description: 'Valuator Olga')
      valuator2 = create(:valuator, user: create(:user, username: 'Miriam'), description: 'Valuator Miriam')
      admin = create(:administrator, user: create(:user, username: 'Gema'))

      budget_investment1.valuators << valuator1
      budget_investment2.valuator_ids = [valuator1.id, valuator2.id]
      budget_investment3.update(administrator_id: admin.id)

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      within("#budget_investment_#{budget_investment1.id}") do
        expect(page).to have_content("No admin assigned")
        expect(page).to have_content("Valuator Olga")
      end

      within("#budget_investment_#{budget_investment2.id}") do
        expect(page).to have_content("No admin assigned")
        expect(page).to have_content("Valuator Olga")
        expect(page).to have_content("Valuator Miriam")
      end

      within("#budget_investment_#{budget_investment3.id}") do
        expect(page).to have_content("Gema")
        expect(page).to have_content("No valuators assigned")
      end
    end

    scenario "Filtering by budget heading", :js do
      group1 = create(:budget_group, name: "Streets", budget: budget)
      group2 = create(:budget_group, name: "Parks", budget: budget)

      group1_heading1 = create(:budget_heading, group: group1, name: "Main Avenue")
      group1_heading2 = create(:budget_heading, group: group1, name: "Mercy Street")
      group2_heading1 = create(:budget_heading, group: group2, name: "Central Park")

      create(:budget_investment, title: "Realocate visitors", budget: budget, group: group1, heading: group1_heading1)
      create(:budget_investment, title: "Change name", budget: budget, group: group1, heading: group1_heading2)
      create(:budget_investment, title: "Plant trees", budget: budget, group: group2, heading: group2_heading1)

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Change name")
      expect(page).to have_link("Plant trees")

      select "Central Park", from: "heading_id"

      expect(page).not_to have_link("Realocate visitors")
      expect(page).not_to have_link("Change name")
      expect(page).to have_link("Plant trees")

      select "All headings", from: "heading_id"

      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Change name")
      expect(page).to have_link("Plant trees")

      select "Streets: Main Avenue", from: "heading_id"

      expect(page).to have_link("Realocate visitors")
      expect(page).not_to have_link("Change name")
      expect(page).not_to have_link("Plant trees")

      select "Streets: Mercy Street", from: "heading_id"

      expect(page).not_to have_link("Realocate visitors")
      expect(page).to have_link("Change name")
      expect(page).not_to have_link("Plant trees")
    end

    scenario "Filtering by admin", :js do
      user = create(:user, username: 'Admin 1')
      administrator = create(:administrator, user: user)

      create(:budget_investment, title: "Realocate visitors", budget: budget, administrator: administrator)
      create(:budget_investment, title: "Destroy the city", budget: budget)

      visit admin_budget_budget_investments_path(budget_id: budget.id)
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "Admin 1", from: "administrator_id"

      expect(page).to have_content('There is 1 investment')
      expect(page).not_to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "All administrators", from: "administrator_id"

      expect(page).to have_content('There are 2 investments')
      expect(page).to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "Admin 1", from: "administrator_id"
      expect(page).to have_content('There is 1 investment')
      expect(page).not_to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")
    end

    scenario "Filtering by valuator", :js do
      user = create(:user)
      valuator = create(:valuator, user: user, description: 'Valuator 1')

      budget_investment = create(:budget_investment, title: "Realocate visitors", budget: budget)
      budget_investment.valuators << valuator

      create(:budget_investment, title: "Destroy the city", budget: budget)

      visit admin_budget_budget_investments_path(budget_id: budget.id)
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "Valuator 1", from: "valuator_id"

      expect(page).to have_content('There is 1 investment')
      expect(page).not_to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "All valuators", from: "valuator_id"

      expect(page).to have_content('There are 2 investments')
      expect(page).to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "Valuator 1", from: "valuator_id"
      expect(page).to have_content('There is 1 investment')
      expect(page).not_to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")
    end

    scenario "Current filter is properly highlighted" do
      filters_links = { 'all' => 'All',
                        'without_admin' => 'Without assigned admin',
                        'without_valuator' => 'Without assigned valuator',
                        'under_valuation' => 'Under valuation',
                        'valuation_finished' => 'Valuation finished' }

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      expect(page).not_to have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit admin_budget_budget_investments_path(budget_id: budget.id, filter: current_filter)

        expect(page).not_to have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

    scenario "Filtering by assignment status" do
      assigned = create(:budget_investment, title: "Assigned idea", budget: budget, administrator: create(:administrator))
      valuating = create(:budget_investment, title: "Evaluating...", budget: budget)
      valuating.valuators.push(create(:valuator))

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'valuation_open')

      expect(page).to have_content("Assigned idea")
      expect(page).to have_content("Evaluating...")

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'without_admin')

      expect(page).to have_content("Evaluating...")
      expect(page).not_to have_content("Assigned idea")

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'without_valuator')

      expect(page).to have_content("Assigned idea")
      expect(page).not_to have_content("Evaluating...")
    end

    scenario "Filtering by valuation status" do
      valuating = create(:budget_investment, budget: budget, title: "Ongoing valuation", administrator: create(:administrator))
      valuated = create(:budget_investment, budget: budget, title: "Old idea", valuation_finished: true)
      valuating.valuators.push(create(:valuator))
      valuated.valuators.push(create(:valuator))

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'under_valuation')

      expect(page).to have_content("Ongoing valuation")
      expect(page).not_to have_content("Old idea")

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'valuation_finished')

      expect(page).not_to have_content("Ongoing valuation")
      expect(page).to have_content("Old idea")

      visit admin_budget_budget_investments_path(budget_id: budget.id, filter: 'all')
      expect(page).to have_content("Ongoing valuation")
      expect(page).to have_content("Old idea")
    end

    scenario "Filtering by tag" do
      create(:budget_investment, budget: budget, title: 'Educate the children', tag_list: 'Education')
      create(:budget_investment, budget: budget, title: 'More schools',         tag_list: 'Education')
      create(:budget_investment, budget: budget, title: 'More hospitals',       tag_list: 'Health')

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      expect(page).to have_css(".budget_investment", count: 3)
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")
      expect(page).to have_content("More hospitals")

      visit admin_budget_budget_investments_path(budget_id: budget.id, tag_name: 'Education')

      expect(page).not_to have_content("More hospitals")
      expect(page).to have_css(".budget_investment", count: 2)
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")
    end

    scenario "Filtering by tag, display only valuation tags" do
      investment1 = create(:budget_investment, budget: budget, tag_list: 'Education')
      investment2 = create(:budget_investment, budget: budget, tag_list: 'Health')

      investment1.set_tag_list_on(:valuation, 'Teachers')
      investment2.set_tag_list_on(:valuation, 'Hospitals')

      investment1.save
      investment2.save

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      expect(page).to have_select("tag_name", options: ["All tags", "Hospitals", "Teachers"])
    end

    scenario "Filtering by tag, display only valuation tags of the current budget" do
      new_budget = create(:budget)
      investment1 = create(:budget_investment, budget: budget, tag_list: 'Roads')
      investment2 = create(:budget_investment, budget: new_budget, tag_list: 'Accessibility')

      investment1.set_tag_list_on(:valuation, 'Roads')
      investment2.set_tag_list_on(:valuation, 'Accessibility')

      investment1.save
      investment2.save

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      expect(page).to have_select("tag_name", options: ["All tags", "Roads"])
      expect(page).not_to have_select("tag_name", options: ["All tags", "Accessibility"])
    end

    scenario "Limiting by max number of investments per heading", :js do
      group_1 = create(:budget_group, budget: budget)
      group_2 = create(:budget_group, budget: budget)
      parks   = create(:budget_heading, group: group_1)

      roads   = create(:budget_heading, group: group_2)
      streets = create(:budget_heading, group: group_2)

      [2, 4, 90, 100, 200, 300].each do |n|
        create(:budget_investment, heading: parks, cached_votes_up: n, title: "Park with #{n} supports")
      end

      [21, 31, 51, 81, 91, 101].each do |n|
        create(:budget_investment, heading: roads, cached_votes_up: n, title: "Road with #{n} supports")
      end

      [3, 10, 30, 33, 44, 55].each do |n|
        create(:budget_investment, heading: streets, cached_votes_up: n, title: "Street with #{n} supports")
      end

      visit admin_budget_budget_investments_path(budget)

      [2, 4, 90, 100, 200, 300].each do |n|
        expect(page).to have_link("Park with #{n} supports")
      end

      [21, 31, 51, 81, 91, 101].each do |n|
        expect(page).to have_link("Road with #{n} supports")
      end

      [3, 10, 30, 33, 44, 55].each do |n|
        expect(page).to have_link("Street with #{n} supports")
      end

      click_link 'Advanced filters'
      fill_in "max_per_heading", with: 5
      click_button 'Filter'

      expect(page).to have_content('There are 15 investments')
      expect(page).not_to have_link("Park with 2 supports")
      expect(page).not_to have_link("Road with 21 supports")
      expect(page).not_to have_link("Street with 3 supports")

      [4, 90, 100, 200, 300].each do |n|
        expect(page).to have_link("Park with #{n} supports")
      end

      [31, 51, 81, 91, 101].each do |n|
        expect(page).to have_link("Road with #{n} supports")
      end

      [10, 30, 33, 44, 55].each do |n|
        expect(page).to have_link("Street with #{n} supports")
      end
    end

  end

  context 'Search' do
    background do
      @budget = create(:budget)
      @investment_1 = create(:budget_investment, title: "Some investment", budget: @budget)
      @investment_2 = create(:budget_investment, title: "Some other investment", budget: @budget)
    end

    scenario "Search investments by title" do
      visit admin_budget_budget_investments_path(@budget)

      expect(page).to have_content(@investment_1.title)
      expect(page).to have_content(@investment_2.title)

      fill_in 'project_title', with: 'Some investment'
      click_button 'Search'

      expect(page).to have_content(@investment_1.title)
      expect(page).to_not have_content(@investment_2.title)
    end
  end

  context 'Sorting' do
    background do
      @budget = create(:budget)
      @investment_1 = create(:budget_investment, title: "BBBB", cached_votes_up: 50, budget: @budget)
      @investment_2 = create(:budget_investment, title: "AAAA", cached_votes_up: 25, budget: @budget)
      @investment_3 = create(:budget_investment, title: "CCCC", cached_votes_up: 10, budget: @budget)
    end

    scenario 'Sort by ID' do
      visit admin_budget_budget_investments_path(@budget, sort_by: 'id')

      expect(@investment_1.title).to appear_before(@investment_2.title)
      expect(@investment_2.title).to appear_before(@investment_3.title)
    end

    scenario 'Sort by title' do
      visit admin_budget_budget_investments_path(@budget, sort_by: 'title')

      expect(@investment_2.title).to appear_before(@investment_1.title)
      expect(@investment_1.title).to appear_before(@investment_3.title)
    end

    scenario 'Sort by supports' do
      visit admin_budget_budget_investments_path(@budget, sort_by: 'supports')

      expect(@investment_3.title).to appear_before(@investment_2.title)
      expect(@investment_2.title).to appear_before(@investment_1.title)
    end
  end

  context 'Show' do
    background do
      @administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
    end

    scenario 'Show the investment details' do
      valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
      budget_investment = create(:budget_investment,
                                  price: 1234,
                                  price_first_year: 1000,
                                  feasibility: "unfeasible",
                                  unfeasibility_explanation: 'It is impossible',
                                  administrator: @administrator)
      budget_investment.valuators << valuator

      visit admin_budget_budget_investments_path(budget_investment.budget)

      click_link budget_investment.title

      expect(page).to have_content(budget_investment.title)
      expect(page).to have_content(budget_investment.description)
      expect(page).to have_content(budget_investment.author.name)
      expect(page).to have_content(budget_investment.heading.name)
      expect(page).to have_content('1234')
      expect(page).to have_content('1000')
      expect(page).to have_content('Unfeasible')
      expect(page).to have_content('It is impossible')
      expect(page).to have_content('Ana (ana@admins.org)')

      within('#assigned_valuators') do
        expect(page).to have_content('Rachel (rachel@valuators.org)')
      end
    end

    scenario "If budget is finished, investment cannot be edited" do
      # Only milestones can be managed

      finished_budget = create(:budget, :finished)
      budget_investment = create(:budget_investment,
                                  budget: finished_budget,
                                  administrator: @administrator)
      visit admin_budget_budget_investments_path(budget_investment.budget)

      click_link budget_investment.title

      expect(page).not_to have_link "Edit"
      expect(page).not_to have_link "Edit classification"
      expect(page).not_to have_link "Edit dossier"
      expect(page).to have_link "Create new milestone"
    end
  end

  context "Edit" do

    scenario "Change title, incompatible, description or heading" do
      budget_investment = create(:budget_investment, :incompatible)
      create(:budget_heading, group: budget_investment.group, name: "Barbate")

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit'

      fill_in 'budget_investment_title', with: 'Potatoes'
      fill_in 'budget_investment_description', with: 'Carrots'
      select "#{budget_investment.group.name}: Barbate", from: 'budget_investment[heading_id]'
      fill_in 'budget_investment_organization_name', with: 'Vegetables'
      uncheck "budget_investment_incompatible"
      check "budget_investment_selected"

      click_button 'Update'

      expect(page).to have_content 'Potatoes'
      expect(page).to have_content 'Carrots'
      expect(page).to have_content 'Barbate'
      expect(page).to have_content 'Representing: Vegetables'
      expect(page).to have_content 'Compatibility: Compatible'
      expect(page).to have_content 'Selected'
    end

    scenario "Compatible non-winner can't edit incompatibility" do
      budget_investment = create(:budget_investment, :selected)
      create(:budget_heading, group: budget_investment.group, name: "Tetuan")

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit'

      expect(page).not_to have_content 'Compatibility'
      expect(page).not_to have_content 'Mark as incompatible'
    end

    scenario "Change visible label" do
      budget_investment = create(:budget_investment)
      create(:budget_heading, group: budget_investment.group, name: "Patroclo")

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit'

      fill_in 'budget_investment_label', with: 'Heroe'
      click_button 'Update'

      visit budget_investment_path(budget_investment.budget, budget_investment)
      expect(page).to have_content 'Heroe'
    end

    scenario "Add administrator" do
      budget_investment = create(:budget_investment)
      administrator = create(:administrator, user: create(:user, username: 'Marta', email: 'marta@admins.org'))

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit classification'

      select 'Marta (marta@admins.org)', from: 'budget_investment[administrator_id]'
      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'
      expect(page).to have_content 'Assigned administrator: Marta'
    end

    scenario "Add valuators" do
      budget_investment = create(:budget_investment)

      valuator1 = create(:valuator, user: create(:user, username: 'Valentina', email: 'v1@valuators.org'))
      valuator2 = create(:valuator, user: create(:user, username: 'Valerian',  email: 'v2@valuators.org'))
      valuator3 = create(:valuator, user: create(:user, username: 'Val',       email: 'v3@valuators.org'))

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit classification'

      check "budget_investment_valuator_ids_#{valuator1.id}"
      check "budget_investment_valuator_ids_#{valuator3.id}"

      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within('#assigned_valuators') do
        expect(page).to have_content('Valentina (v1@valuators.org)')
        expect(page).to have_content('Val (v3@valuators.org)')
        expect(page).not_to have_content('Undefined')
        expect(page).not_to have_content('Valerian (v2@valuators.org)')
      end
    end

    scenario "Adds existing valuation tags", :js do
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      budget_investment1 = create(:budget_investment, heading: heading)
      budget_investment1.set_tag_list_on(:valuation, 'Education, Health')
      budget_investment1.save

      budget_investment2 = create(:budget_investment, heading: heading)

      visit edit_admin_budget_budget_investment_path(budget_investment2.budget, budget_investment2)

      find('.js-add-tag-link', text: 'Education').click

      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within "#tags" do
        expect(page).to have_content 'Education'
        expect(page).not_to have_content 'Health'
      end
    end

    scenario "Adds non existent valuation tags" do
      budget_investment = create(:budget_investment)

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit classification'

      fill_in 'budget_investment_valuation_tag_list', with: 'Refugees, Solidarity'
      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within "#tags" do
        expect(page).to have_content 'Refugees'
        expect(page).to have_content 'Solidarity'
      end
    end

    scenario "Display valuation tags scoped by budget" do
      budget1 = create(:budget)
      budget2 = create(:budget)

      group1 = create(:budget_group, budget: budget1)
      group2 = create(:budget_group, budget: budget2)

      heading1 = create(:budget_heading, group: group1)
      heading2 = create(:budget_heading, group: group2)

      budget_investment1 = create(:budget_investment, heading: heading1)
      budget_investment1.set_tag_list_on(:valuation, 'Education 2017')
      budget_investment1.save

      budget_investment2 = create(:budget_investment, heading: heading2)
      budget_investment2.set_tag_list_on(:valuation, 'Education 2018')
      budget_investment2.save

      visit admin_budget_budget_investment_path(budget1, budget_investment1)
      click_link 'Edit classification'

      within(".tags") do
        expect(page).to have_content "Education 2017"
        expect(page).to_not have_content "Education 2018"
      end
    end

    scenario "Changes valuation and user generated tags" do
      budget_investment = create(:budget_investment, tag_list: 'Park')
      budget_investment.set_tag_list_on(:valuation, 'Education')
      budget_investment.save

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)

      within("#user-tags") do
        expect(page).not_to have_content "Education"
        expect(page).to have_content "Park"
      end

      click_link 'Edit classification'

      fill_in 'budget_investment_tag_list', with: 'Park, Trees'
      fill_in 'budget_investment_valuation_tag_list', with: 'Education, Environment'
      click_button 'Update'

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)

      within("#user-tags") do
        expect(page).not_to have_content "Education"
        expect(page).not_to have_content "Environment"
        expect(page).to have_content "Park, Trees"
      end

      within("#tags") do
        expect(page).to have_content "Education, Environment"
        expect(page).not_to have_content "Park"
        expect(page).not_to have_content "Trees"
      end
    end

    scenario "Maintains user tags" do
      budget_investment = create(:budget_investment, tag_list: 'Park')

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)

      click_link 'Edit classification'

      fill_in 'budget_investment_valuation_tag_list', with: 'Refugees, Solidarity'
      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      visit budget_investment_path(budget_investment.budget, budget_investment)
      expect(page).to have_content "Park"
      expect(page).not_to have_content "Refugees, Solidarity"
    end

    scenario "Shows alert when 'Valuation finished' is checked", :js do
      budget_investment = create(:budget_investment)

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit dossier'

      expect(page).to have_content 'Valuation finished'

      find_field('budget_investment[valuation_finished]').click

      page.accept_confirm("Are you sure you want to mark this report as completed? If you do it, it can no longer be modified.")

      expect(page).to have_field('budget_investment[valuation_finished]', checked: true)
    end

    scenario "Shows alert with unfeasible status when 'Valuation finished' is checked", :js do
      budget_investment = create(:budget_investment)

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit dossier'

      expect(page).to have_content 'Valuation finished'

      find_field('budget_investment_feasibility_unfeasible').click
      find_field('budget_investment[valuation_finished]').click

      page.accept_confirm("Are you sure you want to mark this report as completed? If you do it, it can no longer be modified.\nAn email will be sent immediately to the author of the project with the report of unfeasibility.")

      expect(page).to have_field('budget_investment[valuation_finished]', checked: true)
    end

    scenario "Undoes check in 'Valuation finished' if user clicks 'cancel' on alert", :js do
      budget_investment = create(:budget_investment)

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit dossier'

      dismiss_confirm do
        find_field('budget_investment[valuation_finished]').click
      end

      expect(page).to have_field('budget_investment[valuation_finished]', checked: false)
    end

    scenario "Errors on update" do
      budget_investment = create(:budget_investment)

      visit admin_budget_budget_investment_path(budget_investment.budget, budget_investment)
      click_link 'Edit'

      fill_in 'budget_investment_title', with: ''

      click_button 'Update'

      expect(page).to have_content "can't be blank"
    end

  end

  context "Selecting" do

    let!(:unfeasible_bi)  { create(:budget_investment, :unfeasible, budget: budget, title: "Unfeasible project") }
    let!(:feasible_bi)    { create(:budget_investment, :feasible, budget: budget, title: "Feasible project") }
    let!(:feasible_vf_bi) { create(:budget_investment, :feasible, :finished, budget: budget, title: "Feasible, VF project") }
    let!(:selected_bi)    { create(:budget_investment, :selected, budget: budget, title: "Selected project") }
    let!(:winner_bi)      { create(:budget_investment, :winner, budget: budget, title: "Winner project") }
    let!(:undecided_bi)   { create(:budget_investment, :undecided, budget: budget, title: "Undecided project") }

    scenario "Filtering by valuation and selection", :js do
      visit admin_budget_budget_investments_path(budget)

      within('#filter-subnav') { click_link 'Valuation finished' }
      expect(page).not_to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).to have_content(feasible_vf_bi.title)
      expect(page).to have_content(selected_bi.title)
      expect(page).to have_content(winner_bi.title)

      click_link 'Advanced filters'
      within('#advanced_filters') { find(:css, "#advanced_filters_[value='feasible']").set(true) }
      click_button 'Filter'

      expect(page).not_to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).to have_content(feasible_vf_bi.title)
      expect(page).to have_content(selected_bi.title)
      expect(page).to have_content(winner_bi.title)

      within('#advanced_filters') { find(:css, "#advanced_filters_[value='selected']").set(true) }
      within('#advanced_filters') { find(:css, "#advanced_filters_[value='feasible']").set(false) }
      click_button 'Filter'

      expect(page).not_to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).not_to have_content(feasible_vf_bi.title)
      expect(page).to have_content(selected_bi.title)
      expect(page).to have_content(winner_bi.title)

      within('#filter-subnav') { click_link 'Winners' }
      expect(page).not_to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).not_to have_content(feasible_vf_bi.title)
      expect(page).not_to have_content(selected_bi.title)
      expect(page).to have_content(winner_bi.title)
    end

    scenario "Aggregating results", :js do
      visit admin_budget_budget_investments_path(budget)

      click_link 'Advanced filters'
      within('#advanced_filters') { find(:css, "#advanced_filters_[value='undecided']").set(true) }
      click_button 'Filter'

      expect(page).to have_content(undecided_bi.title)
      expect(page).not_to have_content(winner_bi.title)
      expect(page).not_to have_content(selected_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).not_to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(feasible_vf_bi.title)

      within('#advanced_filters') { find(:css, "#advanced_filters_[value='unfeasible']").set(true) }
      click_button 'Filter'

      expect(page).to have_content(undecided_bi.title)
      expect(page).to have_content(unfeasible_bi.title)
      expect(page).not_to have_content(winner_bi.title)
      expect(page).not_to have_content(selected_bi.title)
      expect(page).not_to have_content(feasible_bi.title)
      expect(page).not_to have_content(feasible_vf_bi.title)
    end

    scenario "Showing the selection buttons", :js do
      visit admin_budget_budget_investments_path(budget)

      within("#budget_investment_#{unfeasible_bi.id}") do
        expect(page).not_to have_link('Select')
        expect(page).not_to have_link('Selected')
      end

      within("#budget_investment_#{feasible_bi.id}") do
        expect(page).not_to have_link('Select')
        expect(page).not_to have_link('Selected')
      end

      within("#budget_investment_#{feasible_vf_bi.id}") do
        expect(page).to have_link('Select')
        expect(page).not_to have_link('Selected')
      end

      within("#budget_investment_#{selected_bi.id}") do
        expect(page).not_to have_link('Select')
        expect(page).to have_link('Selected')
      end
    end

    scenario "Selecting an investment", :js do
      visit admin_budget_budget_investments_path(budget)

      within("#budget_investment_#{feasible_vf_bi.id}") do
        click_link('Select')
        expect(page).to have_link('Selected')
      end

      click_link 'Advanced filters'
      within('#advanced_filters') { find(:css, "#advanced_filters_[value='selected']").set(true) }
      click_button 'Filter'

      within("#budget_investment_#{feasible_vf_bi.id}") do
        expect(page).not_to have_link('Select')
        expect(page).to have_link('Selected')
      end
    end

    scenario "Unselecting an investment", :js do
      visit admin_budget_budget_investments_path(budget)
      click_link 'Advanced filters'

      within('#advanced_filters') { find(:css, "#advanced_filters_[value='selected']").set(true) }

      click_button 'Filter'

      expect(page).to have_content('There are 2 investments')

      within("#budget_investment_#{selected_bi.id}") do
        click_link('Selected')
      end

      visit admin_budget_budget_investments_path(budget)

      within("#budget_investment_#{selected_bi.id}") do
        expect(page).to have_link('Select')
        expect(page).not_to have_link('Selected')
      end
    end
  end

  context "Selecting csv" do

    scenario "Downloading CSV file" do
      investment = create(:budget_investment, :feasible, budget: budget,
                                                         price: 100)
      valuator = create(:valuator, user: create(:user, username: 'Rachel',
                                                       email: 'rachel@val.org'))
      investment.valuators.push(valuator)

      admin = create(:administrator, user: create(:user, username: 'Gema'))
      investment.update(administrator_id: admin.id)

      visit admin_budget_budget_investments_path(budget_id: budget.id)

      click_link "Download current selection"

      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="budget_investments.csv"$/)

      valuators = investment.valuators.collect(&:description_or_name).join(', ')
      feasibility_string = "admin.budget_investments.index"\
                           ".feasibility.#{investment.feasibility}"
      price = I18n.t(feasibility_string, price: investment.formatted_price)

      expect(page).to have_content investment.title
      expect(page).to have_content investment.total_votes.to_s
      expect(page).to have_content investment.id.to_s
      expect(page).to have_content investment.heading.name

      expect(page).to have_content investment.administrator.name
      expect(page).to have_content valuators
      expect(page).to have_content price
      expect(page).to have_content I18n.t('shared.no')
    end

    scenario "Downloading CSV file with applied filter" do
      investment1 = create(:budget_investment, :unfeasible, budget: budget,
                                                            title: 'compatible')
      investment2 = create(:budget_investment, :finished, budget: budget,
                                                          title: 'finished')

      visit admin_budget_budget_investments_path(budget_id: budget.id)
      within('#filter-subnav') { click_link 'Valuation finished' }

      click_link "Download current selection"

      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="budget_investments.csv"$/)

      expect(page).to have_content investment2.title
      expect(page).not_to have_content investment1.title
    end
  end

  context "Mark as visible to valuators" do

    scenario "Mark as visible to valuator", :js do
      valuator = create(:valuator)
      admin = create(:administrator)

      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)

      investment1.valuators << valuator
      investment2.valuators << valuator
      investment1.update(administrator: admin)
      investment2.update(administrator: admin)

      visit admin_budget_budget_investments_path(budget)
      within('#filter-subnav') { click_link 'Under valuation' }

      within("#budget_investment_#{investment1.id}") do
        check "budget_investment_visible_to_valuators"
      end

      login_as(valuator.user.reload)
      visit root_path
      click_link "Admin"
      click_link "Valuation"

      within "#budget_#{budget.id}" do
        click_link "Evaluate"
      end

      expect(page).to     have_content investment1.title
      expect(page).not_to have_content investment2.title
    end

    scenario "Unmark as visible to valuator", :js do
      Setting['feature.budgets.valuators_allowed'] = true

      valuator = create(:valuator)
      admin = create(:administrator)

      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      investment1 = create(:budget_investment, heading: heading, visible_to_valuators: true)
      investment2 = create(:budget_investment, heading: heading, visible_to_valuators: true)

      investment1.valuators << valuator
      investment2.valuators << valuator
      investment1.update(administrator: admin)
      investment2.update(administrator: admin)

      visit admin_budget_budget_investments_path(budget)
      within('#filter-subnav') { click_link 'Under valuation' }

      within("#budget_investment_#{investment1.id}") do
        uncheck "budget_investment_visible_to_valuators"
      end

      login_as(valuator.user.reload)
      visit root_path
      click_link "Admin"
      click_link "Valuation"

      within "#budget_#{budget.id}" do
        click_link "Evaluate"
      end

      expect(page).not_to have_content investment1.title
      expect(page).to     have_content investment2.title
    end

    scenario "Showing the valuating checkbox" do
      investment1 = create(:budget_investment, budget: budget, visible_to_valuators: true)
      investment2 = create(:budget_investment, budget: budget, visible_to_valuators: false)

      investment1.valuators << create(:valuator)
      investment2.valuators << create(:valuator)
      investment2.valuators << create(:valuator)
      investment1.update(administrator: create(:administrator))
      investment2.update(administrator: create(:administrator))

      visit admin_budget_budget_investments_path(budget)

      expect(page).not_to have_css("#budget_investment_visible_to_valuators")

      within('#filter-subnav') { click_link 'Under valuation' }

      within("#budget_investment_#{investment1.id}") do
        valuating_checkbox = find('#budget_investment_visible_to_valuators')
        expect(valuating_checkbox).to be_checked
      end

      within("#budget_investment_#{investment2.id}") do
        valuating_checkbox = find('#budget_investment_visible_to_valuators')
        expect(valuating_checkbox).not_to be_checked
      end
    end
  end

  context "Spending Proposals migrated to Budget Investments should keep the original IDs on lists & urls" do
    let(:spending_proposal) { create(:spending_proposal, id: 9999, title: 'Le Spending Proposal') }
    let(:spending_proposal_migrated_to_budget_investment_path) { "/admin/budgets/#{budget.id}/budget_investments/#{spending_proposal.id}" }
    let!(:associated_budget_investment) do
      create(:budget_investment, id: 8888, budget: budget, title: 'Budget Investment child',
                                 original_spending_proposal_id: spending_proposal.id)
    end

    scenario "A Budget Investment generated from a Spending Proposal should be listed & linked with original Spending Proposal id" do
      visit admin_budget_budget_investments_path(budget)

      within("#budget_investment_#{associated_budget_investment.id}") do
        expect(page).to have_link("Budget Investment child", href: spending_proposal_migrated_to_budget_investment_path)
      end
    end

    scenario "A Budget Investment generated from a Spending Proposal should be accesible by original Spending Proposal id" do
      visit admin_budget_budget_investment_path(budget_id: budget.id, id: spending_proposal.id)

      expect(current_path).to eq(spending_proposal_migrated_to_budget_investment_path)
      expect(page).to have_content("Budget Investment child")
    end

    scenario "A Budget Investment generated from a Spending Proposal should be accesible by its own id" do
      visit admin_budget_budget_investment_path(budget_id: budget.id, id: associated_budget_investment.id)

      expect(page).to have_content("Budget Investment child")
    end
  end

end
