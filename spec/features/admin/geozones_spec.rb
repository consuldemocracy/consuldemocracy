require 'rails_helper'

feature 'Admin geozones' do

  background do
    login_as(create(:administrator).user)
  end

  scenario 'Show list of geozones' do
    chamberi = create(:geozone, name: 'Chamberí')
    retiro = create(:geozone, name: 'Retiro')

    visit admin_geozones_path

    expect(page).to have_content(chamberi.name)
    expect(page).to have_content(retiro.name)
  end

  scenario 'Create new geozone' do
    visit admin_root_path

    within('#side_menu') do
      click_link "Manage geozones"
    end

    click_link "Create geozone"

    fill_in 'geozone_name', with: 'Fancy District'
    fill_in 'geozone_external_code', with: 123
    fill_in 'geozone_census_code', with: 44

    click_button 'Save changes'

    expect(page).to have_content 'Fancy District'

    visit admin_geozones_path

    expect(page).to have_content 'Fancy District'
  end

  scenario 'Edit geozone with no associated elements' do
    target_geozone = create(:geozone, name: 'Edit me!', census_code: '012')

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") do
      click_link "Edit"
    end

    fill_in 'geozone_name', with: 'New geozone name'
    fill_in 'geozone_census_code', with: '333'

    click_button 'Save changes'

    within("#geozone_#{target_geozone.id}") do
      expect(page).to have_content 'New geozone name'
      expect(page).to have_content '333'
    end
  end

  scenario 'Edit geozone with associated elements' do
    target_geozone = create(:geozone, name: 'Edit me!')
    proposal = create(:proposal, title: 'Proposal with geozone', geozone: target_geozone)

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") do
      click_link "Edit"
    end

    fill_in 'geozone_name', with: 'New geozone name'

    click_button 'Save changes'

    expect(proposal.geozone.name).to eq('New geozone name')
  end
end
