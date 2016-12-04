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
end
