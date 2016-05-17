require 'rails_helper'

feature 'Admin spending proposals' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do

    scenario 'Disabled with a feature flag' do
      Setting['feature.spending_proposals'] = nil
      expect{ visit admin_spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    background do
      Setting['feature.spending_proposal_features.valuation_allowed'] = true
    end

    scenario 'Displaying spending proposals' do
      spending_proposal = create(:spending_proposal, cached_votes_up: 10, physical_votes: 20)
      visit admin_spending_proposals_path

      expect(page).to have_content(spending_proposal.title)
      expect(page).to have_css(".total-votes", text: 30)
    end

    scenario 'Displaying assignments info' do
      spending_proposal1 = create(:spending_proposal)
      spending_proposal2 = create(:spending_proposal)
      spending_proposal3 = create(:spending_proposal)

      valuator1 = create(:valuator, user: create(:user, username: 'Olga'), description: 'Valuator Olga')
      valuator2 = create(:valuator, user: create(:user, username: 'Miriam'), description: 'Valuator Miriam')
      admin = create(:administrator, user: create(:user, username: 'Gema'))

      spending_proposal1.valuators << valuator1
      spending_proposal2.valuator_ids = [valuator1.id, valuator2.id]
      spending_proposal3.update({administrator_id: admin.id})

      visit admin_spending_proposals_path

      within("#spending_proposal_#{spending_proposal1.id}") do
        expect(page).to have_content("No admin assigned")
        expect(page).to have_content("Valuator Olga")
      end

      within("#spending_proposal_#{spending_proposal2.id}") do
        expect(page).to have_content("No admin assigned")
        expect(page).to have_content("Valuator Olga")
        expect(page).to have_content("Valuator Miriam")
      end

      within("#spending_proposal_#{spending_proposal3.id}") do
        expect(page).to have_content("Gema")
        expect(page).to have_content("No valuators assigned")
      end
    end

    scenario "Filtering by geozone", :js do
      geozone = create(:geozone, name: "District 9")
      create(:spending_proposal, title: "Realocate visitors", geozone: geozone)
      create(:spending_proposal, title: "Destroy the city")

      visit admin_spending_proposals_path
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "All city", from: "geozone_id"

      expect(page).to have_link("Destroy the city")
      expect(page).to_not have_link("Realocate visitors")

      select "All zones", from: "geozone_id"
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "District 9", from: "geozone_id"

      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      click_link("Realocate visitors")
      click_link("Back")

      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      click_link("Realocate visitors")
      click_link("Edit classification")
      expect(page).to have_button("Update")
      click_link("Back")
      expect(page).to_not have_button("Update")
      click_link("Back")

      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

    end

    scenario "Filtering by admin", :js do
      user = create(:user, username: 'Admin 1')
      administrator = create(:administrator, user: user)

      create(:spending_proposal, title: "Realocate visitors", administrator: administrator)
      create(:spending_proposal, title: "Destroy the city")

      visit admin_spending_proposals_path
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "Admin 1", from: "administrator_id"

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "All administrators", from: "administrator_id"

      expect(page).to have_content('There are 2 investment projects')
      expect(page).to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "Admin 1", from: "administrator_id"
      expect(page).to have_content('There is 1 investment project')
      click_link("Realocate visitors")
      click_link("Back")

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      click_link("Realocate visitors")
      click_link("Edit classification")
      expect(page).to have_button("Update")
      click_link("Back")
      expect(page).to_not have_button("Update")
      click_link("Back")

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

    end

    scenario "Filtering by valuator", :js do
      user = create(:user)
      valuator = create(:valuator, user: user, description: 'Valuator 1')

      spending_proposal = create(:spending_proposal, title: "Realocate visitors")
      spending_proposal.valuators << valuator

      create(:spending_proposal, title: "Destroy the city")

      visit admin_spending_proposals_path
      expect(page).to have_link("Realocate visitors")
      expect(page).to have_link("Destroy the city")

      select "Valuator 1", from: "valuator_id"

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "All valuators", from: "valuator_id"

      expect(page).to have_content('There are 2 investment projects')
      expect(page).to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "Valuator 1", from: "valuator_id"
      expect(page).to have_content('There is 1 investment project')
      click_link("Realocate visitors")
      click_link("Back")

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      click_link("Realocate visitors")
      click_link("Edit classification")
      expect(page).to have_button("Update")
      click_link("Back")
      expect(page).to_not have_button("Update")
      click_link("Back")

      expect(page).to have_content('There is 1 investment project')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")
    end

    scenario "Current filter is properly highlighted" do
      filters_links = {'valuation_open' => 'Open',
                       'without_admin' => 'Without assigned admin',
                       'managed' => 'Managed',
                       'valuating' => 'Under valuation',
                       'valuation_finished' => 'Valuation finished',
                       'all' => 'All'}

      visit admin_spending_proposals_path

      expect(page).to_not have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit admin_spending_proposals_path(filter: current_filter)

        expect(page).to_not have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

    scenario "Filtering by assignment status" do
      assigned = create(:spending_proposal, title: "Assigned idea", administrator: create(:administrator))
      valuating = create(:spending_proposal, title: "Evaluating...")
      valuating.valuators << create(:valuator)

      visit admin_spending_proposals_path(filter: 'valuation_open')

      expect(page).to have_content("Assigned idea")
      expect(page).to have_content("Evaluating...")

      visit admin_spending_proposals_path(filter: 'without_admin')

      expect(page).to have_content("Evaluating...")
      expect(page).to_not have_content("Assigned idea")

      visit admin_spending_proposals_path(filter: 'managed')

      expect(page).to have_content("Assigned idea")
      expect(page).to_not have_content("Evaluating...")
    end

    scenario "Filtering by valuation status" do
      valuating = create(:spending_proposal, title: "Ongoing valuation")
      valuated = create(:spending_proposal, title: "Old idea", valuation_finished: true)
      valuating.valuators << create(:valuator)
      valuated.valuators << create(:valuator)

      visit admin_spending_proposals_path(filter: 'valuation_open')

      expect(page).to have_content("Ongoing valuation")
      expect(page).to_not have_content("Old idea")

      visit admin_spending_proposals_path(filter: 'valuating')

      expect(page).to have_content("Ongoing valuation")
      expect(page).to_not have_content("Old idea")

      visit admin_spending_proposals_path(filter: 'valuation_finished')

      expect(page).to_not have_content("Ongoing valuation")
      expect(page).to have_content("Old idea")

      visit admin_spending_proposals_path(filter: 'all')
      expect(page).to have_content("Ongoing valuation")
      expect(page).to have_content("Old idea")
    end

    scenario "Filtering by tag" do
      create(:spending_proposal, title: 'Educate the children', tag_list: 'Education')
      create(:spending_proposal, title: 'More schools',         tag_list: 'Education')
      create(:spending_proposal, title: 'More hospitals',       tag_list: 'Health')

      visit admin_spending_proposals_path

      expect(page).to have_css(".spending_proposal", count: 3)
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")
      expect(page).to have_content("More hospitals")

      visit admin_spending_proposals_path(tag_name: 'Education')

      expect(page).to_not have_content("More hospitals")
      expect(page).to have_css(".spending_proposal", count: 2)
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")

      click_link("Educate the children")
      click_link("Back")

      expect(page).to_not have_content("More hospitals")
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")

      click_link("Educate the children")
      click_link("Edit classification")
      expect(page).to have_button("Update")
      click_link("Back")
      expect(page).to_not have_button("Update")
      click_link("Back")

      expect(page).to_not have_content("More hospitals")
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")
    end

    context "Limiting the number of proposals" do
      scenario "Limiting by geozone", :js do
        california = create(:geozone)
        new_york   = create(:geozone)

        [2, 3, 5, 10, 20, 99].each do |votes|
          create(:spending_proposal, geozone: california, cached_votes_up: votes, title: "Cali with #{votes} supports")
          create(:spending_proposal, geozone: new_york, cached_votes_up: votes, title: "NY voted #{votes} times")
        end

        visit admin_spending_proposals_path

        [2, 3, 5, 10, 20, 99].each do |votes|
          expect(page).to have_link "Cali with #{votes} supports"
          expect(page).to have_link "NY voted #{votes} times"
        end

        select "5", from: "max_per_geozone"

        expect(page).to have_content('There are 10 investment projects')
        expect(page).to_not have_link "Cali with 2 supports"
        expect(page).to_not have_link "NY voted 2 times"
      end

      scenario "Limiting the proposals with no geozone", :js do
        [2, 3, 5, 10, 20, 99].each do |votes|
          create(:spending_proposal, cached_votes_up: votes, title: "#{votes} supports!")
        end

        visit admin_spending_proposals_path

        [2, 3, 5, 10, 20, 99].each do |votes|
          expect(page).to have_link "#{votes} supports!"
        end

        select "5", from: "max_for_no_geozone"

        expect(page).to have_content('There are 5 investment projects')
        expect(page).to_not have_link "2 supports!"
      end

      scenario "Limiting both", :js do
        skane = create(:geozone)

        [10, 20, 99].each do |votes|
          create(:spending_proposal, geozone: skane, cached_votes_up: votes, title: "Skane with #{votes} supports")
          create(:spending_proposal, cached_votes_up: votes, title: "No geozone, #{votes} supports")
        end

        visit admin_spending_proposals_path

        [10, 20, 99].each do |votes|
          expect(page).to have_link "Skane with #{votes} supports"
          expect(page).to have_link "No geozone, #{votes} supports"
        end

        visit admin_spending_proposals_path(max_for_no_geozone: 2, max_per_geozone: 1)

        expect(page).to have_content('There are 3 investment projects')
        expect(page).to have_link "Skane with 99 supports"
        expect(page).to_not have_link "Skane with 20 supports"
        expect(page).to_not have_link "Skane with 10 supports"
        expect(page).to have_link "No geozone, 99 supports"
        expect(page).to have_link "No geozone, 20 supports"
        expect(page).to_not have_link "No geozone, 10 supports"
      end
    end

  end

  scenario 'Show' do
    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
    valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood',
                                price: 1234,
                                price_first_year: 1000,
                                feasible: false,
                                feasible_explanation: 'It is impossible',
                                administrator: administrator)
    spending_proposal.valuators << valuator

    visit admin_spending_proposals_path

    click_link spending_proposal.title

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
    expect(page).to have_content('1234')
    expect(page).to have_content('1000')
    expect(page).to have_content('Not feasible')
    expect(page).to have_content('It is impossible')
    expect(page).to have_content('Ana (ana@admins.org)')

    within('#assigned_valuators') do
      expect(page).to have_content('Rachel (rachel@valuators.org)')
    end
  end

  context "Edit" do

    background do
      Setting['feature.spending_proposal_features.valuation_allowed'] = true
    end

    scenario "Change title, description or geozone" do
      spending_proposal = create(:spending_proposal)
      create(:geozone, name: "Barbate")

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit'

      fill_in 'spending_proposal_title', with: 'Potatoes'
      fill_in 'spending_proposal_description', with: 'Carrots'
      select 'Barbate', from: 'spending_proposal[geozone_id]'

      click_button 'Update'

      expect(page).to have_content 'Potatoes'
      expect(page).to have_content 'Carrots'
      expect(page).to have_content 'Barbate'
    end

    scenario "Add administrator" do
      spending_proposal = create(:spending_proposal)
      administrator = create(:administrator, user: create(:user, username: 'Marta', email: 'marta@admins.org'))

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit classification'

      select 'Marta (marta@admins.org)', from: 'spending_proposal[administrator_id]'
      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'
      expect(page).to have_content 'Assigned administrator: Marta'
    end

    scenario "Add valuators" do
      spending_proposal = create(:spending_proposal)

      valuator1 = create(:valuator, user: create(:user, username: 'Valentina', email: 'v1@valuators.org'))
      valuator2 = create(:valuator, user: create(:user, username: 'Valerian',  email: 'v2@valuators.org'))
      valuator3 = create(:valuator, user: create(:user, username: 'Val',       email: 'v3@valuators.org'))

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit classification'

      check "spending_proposal_valuator_ids_#{valuator1.id}"
      check "spending_proposal_valuator_ids_#{valuator3.id}"

      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within('#assigned_valuators') do
        expect(page).to have_content('Valentina (v1@valuators.org)')
        expect(page).to have_content('Val (v3@valuators.org)')
        expect(page).to_not have_content('Undefined')
        expect(page).to_not have_content('Valerian (v2@valuators.org)')
      end
    end

    scenario "Adds existing tags", :js do
      create(:spending_proposal, tag_list: 'Education, Health')

      spending_proposal = create(:spending_proposal)

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit classification'

      find('.js-add-tag-link', text: 'Education').click

      fill_in 'spending_proposal_title', with: 'Updated title'

      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within "#tags" do
        expect(page).to have_content 'Education'
        expect(page).to_not have_content 'Health'
      end
    end

    scenario "Adds non existent tags" do
      spending_proposal = create(:spending_proposal)

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit classification'

      fill_in 'spending_proposal_tag_list', with: 'Refugees, Solidarity'
      click_button 'Update'

      expect(page).to have_content 'Investment project updated succesfully.'

      within "#tags" do
        expect(page).to have_content 'Refugees'
        expect(page).to have_content 'Solidarity'
      end
    end

    scenario "Errors on update" do
      spending_proposal = create(:spending_proposal)
      create(:geozone, name: "Barbate")

      visit admin_spending_proposal_path(spending_proposal)
      click_link 'Edit'

      fill_in 'spending_proposal_title', with: ''

      click_button 'Update'

      expect(page).to have_content "can't be blank"
    end

  end

  context 'Summary' do

    scenario "Diplays cost for every geozone" do
      california = create(:geozone)
      new_york   = create(:geozone)

      proposal1 = create(:spending_proposal, price: '10000000', geozone: nil,        feasible: true, valuation_finished: true)
      proposal1 = create(:spending_proposal, price: '5000000',  geozone: nil,        feasible: true, valuation_finished: true)
      proposal3 = create(:spending_proposal, price: '1000000',  geozone: california, feasible: true, valuation_finished: true)
      proposal4 = create(:spending_proposal, price: '500000',   geozone: california, feasible: true, valuation_finished: true)
      proposal5 = create(:spending_proposal, price: '30000',    geozone: new_york,   feasible: true, valuation_finished: true)

      visit admin_spending_proposals_path

      click_link "Investment project summary"

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".name",                        text: "All city")
        expect(page).to have_css(".finished-and-feasible-count", text: 2)
        expect(page).to have_css(".total-price",                 text: "$15,000,000")
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".name",                        text: california.name)
        expect(page).to have_css(".finished-and-feasible-count", text: 2)
        expect(page).to have_css(".total-price",                 text: "$1,500,000")
      end

      within("#geozone_#{new_york.id}") do
        expect(page).to have_css(".name",                        text: new_york.name)
        expect(page).to have_css(".finished-and-feasible-count", text: 1)
        expect(page).to have_css(".total-price",                 text: '$30,000')
      end
    end

    scenario "Displays total number of proposals for every geozone" do
      california = create(:geozone)
      new_york   = create(:geozone)

      proposal1 = create(:spending_proposal, geozone: nil)
      proposal1 = create(:spending_proposal, geozone: nil)
      proposal3 = create(:spending_proposal, geozone: california)
      proposal4 = create(:spending_proposal, geozone: california)
      proposal5 = create(:spending_proposal, geozone: new_york)

      visit admin_spending_proposals_path

      click_link "Investment project summary"

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".total-count", text: 2)
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".total-count", text: 2)
      end

      within("#geozone_#{new_york.id}") do
        expect(page).to have_css(".total-count", text: 1)
      end

    end

    scenario "Displays finished and unfeasible for every geozone" do
      california = create(:geozone)
      new_york   = create(:geozone)

      proposal1 = create(:spending_proposal, geozone: nil,        feasible: false, valuation_finished: true)
      proposal2 = create(:spending_proposal, geozone: nil,        feasible: false, valuation_finished: true)
      proposal3 = create(:spending_proposal, geozone: california, feasible: false, valuation_finished: true)
      proposal4 = create(:spending_proposal, geozone: california, feasible: false, valuation_finished: true)
      proposal5 = create(:spending_proposal, geozone: new_york,   feasible: false, valuation_finished: true)
      proposal6 = create(:spending_proposal, geozone: new_york,   feasible: true,  valuation_finished: true)
      proposal6 = create(:spending_proposal, geozone: new_york,   feasible: false, valuation_finished: false)

      visit admin_spending_proposals_path

      click_link "Investment project summary"

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".finished-and-unfeasible-count", text: 2)
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".finished-and-unfeasible-count", text: 2)
      end

      within("#geozone_#{new_york.id}") do
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
      end
    end

    scenario "Displays finished proposals for every geozone" do
      california = create(:geozone)
      new_york   = create(:geozone)

      proposal1 = create(:spending_proposal, geozone: nil,        valuation_finished: true)
      proposal2 = create(:spending_proposal, geozone: nil,        valuation_finished: true)
      proposal3 = create(:spending_proposal, geozone: california, valuation_finished: true)
      proposal4 = create(:spending_proposal, geozone: california, valuation_finished: true)
      proposal5 = create(:spending_proposal, geozone: new_york,   valuation_finished: true)
      proposal6 = create(:spending_proposal, geozone: new_york,   valuation_finished: false)

      visit admin_spending_proposals_path

      click_link "Investment project summary"

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".finished-count", text: 2)
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".finished-count", text: 2)
      end

      within("#geozone_#{new_york.id}") do
        expect(page).to have_css(".finished-count", text: 1)
      end
    end

    scenario "Displays proposals in evaluation for every geozone" do
      california = create(:geozone)
      new_york   = create(:geozone)

      proposal1 = create(:spending_proposal, geozone: nil,        valuation_finished: false)
      proposal2 = create(:spending_proposal, geozone: nil,        valuation_finished: false)
      proposal3 = create(:spending_proposal, geozone: california, valuation_finished: false)
      proposal4 = create(:spending_proposal, geozone: california, valuation_finished: false)
      proposal5 = create(:spending_proposal, geozone: new_york,   valuation_finished: false)

      valuator = create(:valuator, user: create(:user, username: 'Olga'))
      SpendingProposal.all.each do |sp|
        sp.valuators << valuator
      end

      proposal6 = create(:spending_proposal, geozone: new_york, valuation_finished: false)

      visit admin_spending_proposals_path

      click_link "Investment project summary"

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".in-evaluation-count", text: 2)
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".in-evaluation-count", text: 2)
      end

      within("#geozone_#{new_york.id}") do
        expect(page).to have_css(".in-evaluation-count", text: 1)
      end
    end

    scenario "Can be limited to top results by geozone", :js do
      california = create(:geozone)

      create(:spending_proposal, :with_confidence_score, cached_votes_up: 1 ,  price: '10000000', geozone: nil,        feasible: true, valuation_finished: true)
      create(:spending_proposal, :with_confidence_score, cached_votes_up: 100, price: '5000000',  geozone: nil,        feasible: false, valuation_finished: true)
      create(:spending_proposal, :with_confidence_score, cached_votes_up:  1,  price: '1000000',  geozone: california, feasible: true, valuation_finished: true)
      create(:spending_proposal, :with_confidence_score, cached_votes_up: 100, price: '500000',   geozone: california, feasible: false, valuation_finished: true)
      create(:spending_proposal, :with_confidence_score, cached_votes_up: 10,  price: '30000',    geozone: california, feasible: true, valuation_finished: true)

      visit summary_admin_spending_proposals_path(max_for_no_geozone: 1, max_per_geozone: 2)

      expect(page).to have_content "Summary for investment projects"

      within("#geozone_all_city") do
        expect(page).to have_css(".name",                          text: "All city")
        expect(page).to have_css(".finished-and-feasible-count",   text: 0)
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
        expect(page).to have_css(".total-price",                   text: "$5,000,000")
      end

      within("#geozone_#{california.id}") do
        expect(page).to have_css(".name",                          text: california.name)
        expect(page).to have_css(".finished-and-feasible-count",   text: 1)
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
        expect(page).to have_css(".total-price",                   text: "$530,000")
      end
    end

  end

  context 'Valuators Summary' do
    scenario "Display info on valuator's assigned pending proposals" do
      proposal1 = create(:spending_proposal, price: '10000000', geozone: nil, feasible: true, valuation_finished: true)
      proposal2 = create(:spending_proposal, price: '5000000',  geozone: nil, feasible: false, valuation_finished: true)
      valuator = create(:valuator, description: 'SuperValuator')
      proposal1.valuators << valuator
      proposal2.valuators << valuator

      visit summary_admin_valuators_path

      within("#valuator_#{valuator.id}") do
        expect(page).to have_css(".name",                          text: "SuperValuator")
        expect(page).to have_css(".finished-and-feasible-count",   text: 1)
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
        expect(page).to have_css(".total-price",                   text: "$15,000,000")
      end
    end

    scenario "Can be limited to top results by geozone", :js do
      california = create(:geozone)
      valuator1 = create(:valuator, description: 'Valuator number 1')
      valuatorA = create(:valuator, description: 'Valuator series A')

      proposal1 = create(:spending_proposal, :with_confidence_score, cached_votes_up: 100, price: '100',  geozone: nil,        feasible: true, valuation_finished: true)
      proposal2 = create(:spending_proposal, :with_confidence_score, cached_votes_up: 1,   price: '8000', geozone: nil,        feasible: false, valuation_finished: true)
      proposal3 = create(:spending_proposal, :with_confidence_score, cached_votes_up: 50,  price: '5000', geozone: california, feasible: false, valuation_finished: true)
      proposalA = create(:spending_proposal, :with_confidence_score, cached_votes_up: 10,  price: '10',   geozone: nil,        feasible: true, valuation_finished: true)
      proposalB = create(:spending_proposal, :with_confidence_score, cached_votes_up: 5,   price: '1000', geozone: california, feasible: true, valuation_finished: true)
      proposalC = create(:spending_proposal, :with_confidence_score, cached_votes_up: 500, price: '7000', geozone: california, feasible: false, valuation_finished: true)

      proposal1.valuators << valuator1
      proposal2.valuators << valuator1
      proposal3.valuators << valuator1
      proposalA.valuators << valuatorA
      proposalB.valuators << valuatorA
      proposalC.valuators << valuatorA

      visit summary_admin_valuators_path(max_for_no_geozone: 1, max_per_geozone: 2) # 1 3 C

      within("#valuator_#{valuator1.id}") do
        expect(page).to have_css(".name",                          text: "Valuator number 1")
        expect(page).to have_css(".finished-and-feasible-count",   text: 1)
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
        expect(page).to have_css(".total-count",                   text: 2)
        expect(page).to have_css(".total-price",                   text: "$5,100")
      end

      within("#valuator_#{valuatorA.id}") do
        expect(page).to have_css(".name",                          text:  "Valuator series A")
        expect(page).to have_css(".finished-and-feasible-count",   text: 0)
        expect(page).to have_css(".finished-and-unfeasible-count", text: 1)
        expect(page).to have_css(".total-count",                   text: 1)
        expect(page).to have_css(".total-price",                   text: "$7,000")
      end
    end

  end

end
