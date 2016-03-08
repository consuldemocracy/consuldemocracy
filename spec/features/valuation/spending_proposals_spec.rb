require 'rails_helper'

feature 'Valuation spending proposals' do

  background do
    @valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    login_as(@valuator.user)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.spending_proposals'] = nil
    expect{ visit valuation_spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario 'Index shows spending proposals' do
    spending_proposal = create(:spending_proposal)
    visit valuation_spending_proposals_path

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

    visit valuation_spending_proposals_path

    within("#spending_proposal_#{spending_proposal1.id}") do
      expect(page).to have_content("Olga")
    end

    within("#spending_proposal_#{spending_proposal2.id}") do
      expect(page).to have_content("2 valuators assigned")
    end

    within("#spending_proposal_#{spending_proposal3.id}") do
      expect(page).to have_content("No valuators assigned")
    end
  end

  scenario "Index filtering by geozone", :js do
    geozone = create(:geozone, name: "District 9")
    create(:spending_proposal, title: "Realocate visitors", geozone: geozone)
    create(:spending_proposal, title: "Destroy the city")

    visit valuation_spending_proposals_path
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

  scenario "Index filtering by valuator", :js do
    user = create(:user, username: 'Karnak')
    valuator1 = create(:valuator, user: user)

    spending = create(:spending_proposal, title: "Realocate visitors")
    spending.valuators << valuator1
    create(:spending_proposal, title: "Destroy the city")

    visit valuation_spending_proposals_path
    expect(page).to have_link("Realocate visitors")
    expect(page).to have_link("Destroy the city")

    select "Karnak", from: "valuator_id"

    expect(page).to have_link("Realocate visitors")
    expect(page).to_not have_link("Destroy the city")

    select "All valuators", from: "valuator_id"

    expect(page).to have_link("Destroy the city")
    expect(page).to have_link("Realocate visitors")
  end

  scenario "Current filter is properly highlighted" do
    filters_links = {'valuation_open' => 'Open',
                     'valuating' => 'Under valuation',
                     'valuation_finished' => 'Valuation finished'}

    visit valuation_spending_proposals_path

    expect(page).to_not have_link(filters_links.values.first)
    filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

    filters_links.each_pair do |current_filter, link|
      visit valuation_spending_proposals_path(filter: current_filter)

      expect(page).to_not have_link(link)

      (filters_links.keys - [current_filter]).each do |filter|
        expect(page).to have_link(filters_links[filter])
      end
    end
  end

  scenario "Index filtering by valuation status" do
    valuating = create(:spending_proposal, title: "Ongoing valuation")
    valuated = create(:spending_proposal, title: "Old idea", valuation_finished: true)
    valuating.valuators << create(:valuator)
    valuated.valuators << create(:valuator)

    visit valuation_spending_proposals_path(filter: 'valuation_open')

    expect(page).to have_content("Ongoing valuation")
    expect(page).to_not have_content("Old idea")

    visit valuation_spending_proposals_path(filter: 'valuating')

    expect(page).to have_content("Ongoing valuation")
    expect(page).to_not have_content("Old idea")

    visit valuation_spending_proposals_path(filter: 'valuation_finished')

    expect(page).to_not have_content("Ongoing valuation")
    expect(page).to have_content("Old idea")
  end

  scenario 'Show' do
    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
    valuator2 = create(:valuator, user: create(:user, username: 'Rick', email: 'rick@valuators.org'))
    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood',
                                price: 1234.56,
                                feasible: false,
                                feasible_explanation: 'It is impossible',
                                administrator: administrator)
    spending_proposal.valuators << [@valuator, valuator2]

    visit valuation_spending_proposals_path

    click_link spending_proposal.title

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
    expect(page).to have_content('1234.56')
    expect(page).to have_content('Not feasible')
    expect(page).to have_content('It is impossible')
    expect(page).to have_content('Ana (ana@admins.org)')

    within('#assigned_valuators') do
      expect(page).to have_content('Rachel (rachel@valuators.org)')
      expect(page).to have_content('Rick (rick@valuators.org)')
    end
  end

  feature 'Valuate' do
    background do
      @spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                administrator: create(:administrator))
      @spending_proposal.valuators << @valuator
    end

    scenario 'Dossier empty by default' do
      visit valuation_spending_proposals_path
      click_link @spending_proposal.title

      within('#price') { expect(page).to have_content('Undefined') }
      within('#price_first_year') { expect(page).to have_content('Undefined') }
      within('#time_scope') { expect(page).to have_content('Undefined') }
      within('#feasibility') { expect(page).to have_content('Undefined') }
      expect(page).to_not have_content('Valuation finished')
      expect(page).to_not have_content('Internal comments')
    end

    scenario 'Edit dossier' do
      visit valuation_spending_proposals_path
      within("#spending_proposal_#{@spending_proposal.id}") do
        click_link "Edit"
      end

      fill_in 'spending_proposal_price', with: '12345.67'
      fill_in 'spending_proposal_price_first_year', with: '8910.11'
      fill_in 'spending_proposal_price_explanation', with: 'Very cheap idea'
      choose  'spending_proposal_feasible_true'
      fill_in 'spending_proposal_feasible_explanation', with: 'Everything is legal and easy to do'
      fill_in 'spending_proposal_time_scope', with: '19 months'
      fill_in 'spending_proposal_internal_comments', with: 'Should be double checked by the urbanism area'
      click_button 'Save changes'

      expect(page).to have_content "Dossier updated"

      visit valuation_spending_proposals_path
      click_link @spending_proposal.title

      within('#price') { expect(page).to have_content('12345.67') }
      within('#price_first_year') { expect(page).to have_content('8910.11') }
      expect(page).to have_content('Very cheap idea')
      within('#time_scope') { expect(page).to have_content('19 months') }
      within('#feasibility') { expect(page).to have_content('Feasible') }
      expect(page).to_not have_content('Valuation finished')
      expect(page).to have_content('Internal comments')
      expect(page).to have_content('Should be double checked by the urbanism area')
    end

    scenario 'Finish valuation' do
      visit valuation_spending_proposal_path(@spending_proposal)
      click_link 'Edit dossier'

      check 'spending_proposal_valuation_finished'
      click_button 'Save changes'

      visit valuation_spending_proposals_path
      expect(page).to_not have_content @spending_proposal.title
      click_link 'Valuation finished'

      expect(page).to have_content @spending_proposal.title
      click_link @spending_proposal.title
      expect(page).to have_content('Valuation finished')
    end
  end

end
