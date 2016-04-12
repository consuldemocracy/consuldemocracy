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

    scenario 'Displaying spending proposals' do
      spending_proposal = create(:spending_proposal)
      visit admin_spending_proposals_path

      expect(page).to have_content(spending_proposal.title)
    end

    scenario 'Displaying assignments info' do
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
        expect(page).to have_content("Olga")
        expect(page).to have_content("Miriam")
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
      click_on("Edit classification")
      expect(page).to have_button("Update")
      click_on("Back")
      expect(page).to_not have_button("Update")
      click_on("Back")

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
      click_on("Edit classification")
      expect(page).to have_button("Update")
      click_on("Back")
      expect(page).to_not have_button("Update")
      click_on("Back")

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

      expect(page).to have_content('There is 1 spending proposal')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "All valuators", from: "valuator_id"

      expect(page).to have_content('There are 2 spending proposals')
      expect(page).to have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      select "Valuator 1", from: "valuator_id"
      expect(page).to have_content('There is 1 spending proposal')
      click_link("Realocate visitors")
      click_link("Back")

      expect(page).to have_content('There is 1 spending proposal')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")

      click_link("Realocate visitors")
      click_on("Edit classification")
      expect(page).to have_button("Update")
      click_on("Back")
      expect(page).to_not have_button("Update")
      click_on("Back")

      expect(page).to have_content('There is 1 spending proposal')
      expect(page).to_not have_link("Destroy the city")
      expect(page).to have_link("Realocate visitors")
    end

    scenario "Current filter is properly highlighted" do
      filters_links = {'valuation_open' => 'Open',
                       'without_admin' => 'Without assigned admin',
                       'managed' => 'Managed',
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
      click_on("Edit classification")
      expect(page).to have_button("Update")
      click_on("Back")
      expect(page).to_not have_button("Update")
      click_on("Back")

      expect(page).to_not have_content("More hospitals")
      expect(page).to have_content("Educate the children")
      expect(page).to have_content("More schools")
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

  end

end
