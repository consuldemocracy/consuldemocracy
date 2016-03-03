require 'rails_helper'

feature 'Admin spending proposals' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.spending_proposals'] = nil
    expect{ visit admin_spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario 'Index shows spending proposals' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposals_path

    expect(page).to have_content(spending_proposal.title)
  end

  scenario 'Index shows assignments info' do
    spending_proposal1 = create(:spending_proposal)
    spending_proposal2 = create(:spending_proposal)
    spending_proposal3 = create(:spending_proposal)

    valuator1 = create(:valuator, user: create(:user, username: 'Olga'))
    valuator2 = create(:valuator, user: create(:user, username: 'Miriam'))
    admin = create(:administrator, user: create(:user, username: 'Gema'))

    spending_proposal1.valuators << valuator1
    spending_proposal2.valuator_ids = [valuator1.id, valuator2.id]
    spending_proposal3.update({administrator_id: admin.id})

    visit admin_spending_proposals_path

    within("#spending_proposal_#{spending_proposal1.id}") do
      expect(page).to have_content("No admin assigned")
      expect(page).to have_content("Olga")
    end

    within("#spending_proposal_#{spending_proposal2.id}") do
      expect(page).to have_content("No admin assigned")
      expect(page).to have_content("2 valuators assigned")
    end

    within("#spending_proposal_#{spending_proposal3.id}") do
      expect(page).to have_content("Gema")
      expect(page).to have_content("No valuators assigned")
    end
  end

  scenario "Index filtering by geozone", :js do
    geozone = create(:geozone, name: "District 9")
    create(:spending_proposal, title: "Realocate visitors", geozone: geozone)
    create(:spending_proposal, title: "Destroy the city")

    visit admin_spending_proposals_path
    expect(page).to have_link("Realocate visitors")
    expect(page).to have_link("Destroy the city")

    select "District 9", from: "geozone_id"

    expect(page).to have_link("Realocate visitors")
    expect(page).to_not have_link("Destroy the city")

    select "All city", from: "geozone_id"

    expect(page).to have_link("Destroy the city")
    expect(page).to_not have_link("Realocate visitors")

    select "All zones", from: "geozone_id"
    expect(page).to have_link("Realocate visitors")
    expect(page).to have_link("Destroy the city")
  end

  scenario "Current filter is properly highlighted" do
    filters_links = {'all' => 'All',
                     'without_admin' => 'Without assigned admin',
                     'without_valuators' => 'Without valuator',
                     'valuating' => 'Under valuation',
                     'valuation_finished' => 'Valuation finished'}

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

  scenario "Index filtering by assignment status" do
    assigned = create(:spending_proposal, title: "Assigned idea", administrator: create(:administrator))
    valuating = create(:spending_proposal, title: "Evaluating...")
    valuating.valuators << create(:valuator)

    visit admin_spending_proposals_path(filter: 'all')

    expect(page).to have_content("Assigned idea")
    expect(page).to have_content("Evaluating...")

    visit admin_spending_proposals_path(filter: 'without_admin')

    expect(page).to have_content("Evaluating...")
    expect(page).to_not have_content("Assigned idea")

    visit admin_spending_proposals_path(filter: 'without_valuators')

    expect(page).to have_content("Assigned idea")
    expect(page).to_not have_content("Evaluating...")
  end

  scenario "Index filtering by valuation status" do
    valuating = create(:spending_proposal, title: "Ongoing valuation")
    valuated = create(:spending_proposal, title: "Old idea", valuation_finished: true)
    valuating.valuators << create(:valuator)
    valuated.valuators << create(:valuator)

    visit admin_spending_proposals_path(filter: 'all')

    expect(page).to have_content("Ongoing valuation")
    expect(page).to have_content("Old idea")

    visit admin_spending_proposals_path(filter: 'valuating')

    expect(page).to have_content("Ongoing valuation")
    expect(page).to_not have_content("Old idea")

    visit admin_spending_proposals_path(filter: 'valuation_finished')

    expect(page).to_not have_content("Ongoing valuation")
    expect(page).to have_content("Old idea")
  end

  scenario 'Show' do
    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
    valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood',
                                price: 1234.56,
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
    expect(page).to have_content('1234.56')
    expect(page).to have_content('Not feasible')
    expect(page).to have_content('It is impossible')
    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Ana (ana@admins.org)')

    within('#assigned_valuators') do
      expect(page).to have_content('Rachel (rachel@valuators.org)')
    end
  end

  scenario 'Administrator assigment', :js do
    spending_proposal = create(:spending_proposal)

    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))

    visit admin_spending_proposal_path(spending_proposal)

    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Undefined')
    select 'Ana (ana@admins.org)', from: 'spending_proposal[administrator_id]'

    visit admin_spending_proposals_path
    click_link spending_proposal.title

    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Ana (ana@admins.org)')
  end

  scenario 'Valuators assigments', :js do
    spending_proposal = create(:spending_proposal)

    valuator1 = create(:valuator, user: create(:user, username: 'Valentina', email: 'v1@valuators.org'))
    valuator2 = create(:valuator, user: create(:user, username: 'Valerian', email: 'v2@valuators.org'))
    valuator3 = create(:valuator, user: create(:user, username: 'Val', email: 'v3@valuators.org'))

    visit admin_spending_proposal_path(spending_proposal)

    within('#assigned_valuators') do
      expect(page).to have_content('Undefined')
      expect(page).to_not have_content('Valentina (v1@valuators.org)')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
      expect(page).to_not have_content('Val (v3@valuators.org)')
    end

    visit admin_spending_proposal_path(spending_proposal)

    click_link "Assign valuators"

    within('#valuators-assign-list') do
      check "valuator_ids_#{valuator1.id}"
      check "valuator_ids_#{valuator3.id}"
    end

    within('#assigned_valuators') do
      expect(page).to have_content('Valentina (v1@valuators.org)')
      expect(page).to have_content('Val (v3@valuators.org)')
      expect(page).to_not have_content('Undefined')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
    end

    visit admin_spending_proposal_path(spending_proposal)

    within('#assigned_valuators') do
      expect(page).to have_content('Valentina (v1@valuators.org)')
      expect(page).to have_content('Val (v3@valuators.org)')
      expect(page).to_not have_content('Undefined')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
    end
  end
  
  context "Search" do

    background do
       spending_proposal = create(:spending_proposal, geozone: create(:geozone))
       spending_proposal = create(:spending_proposal, 
                 title: 'Testing spending proposal', 
                 description: 'Testing spending proposal', 
                 geozone: create(:geozone) ,              
                 external_url: 'http://http://skyscraperpage.com/')
    end

   scenario "The search is not running if search is empty" do
     visit admin_spending_proposals_path
     fill_in "search", with: "      "
     click_button "Search"
     expect(current_path).to eq(admin_spending_proposals_path)
     expect(page).to have_content("Testing spending proposal")
   end

   scenario "returns no results if search does not exist" do
     visit admin_spending_proposals_path

     fill_in "search", with: "Prueba"
     click_button "Search"
     expect(current_path).to eq(admin_spending_proposals_path)
     expect(page).to_not have_content("Prueba")
     expect(page).to have_content("spending proposals cannot be found")
    end
  
    scenario "finds by title" do
     visit admin_spending_proposals_path

     fill_in "search", with: "Testing"
     click_button "Search"

     expect(current_path).to eq(admin_spending_proposals_path)
     expect(page).to have_content("Testing spending proposal")
    end
  end






end
