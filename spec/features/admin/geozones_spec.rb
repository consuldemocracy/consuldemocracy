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

    expect(proposal.reload.geozone.name).to eq('New geozone name')
  end

  scenario 'Delete geozone with no associated elements' do
    target_geozone = create(:geozone, name: 'Delete me!')

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") { click_link 'Delete' }

    expect(page).not_to have_content('Delete me!')
    expect(Geozone.find_by_id(target_geozone.id)).to be_nil
  end

  scenario 'Delete geozone with associated proposal' do
    target_geozone = create(:geozone, name: 'Delete me!')
    proposal = create(:proposal, geozone: target_geozone)

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") { click_link 'Delete' }

    expect(page).to have_content('Delete me!')
    expect(proposal.reload.geozone).to eq(target_geozone)
  end

  scenario 'Delete geozone with associated spending proposal' do
    target_geozone = create(:geozone, name: 'Delete me!')
    spending_proposal = create(:spending_proposal, geozone: target_geozone)

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") { click_link 'Delete' }

    expect(page).to have_content('Delete me!')
    expect(spending_proposal.reload.geozone).to eq(target_geozone)
  end

  scenario 'Delete geozone with associated debate' do
    target_geozone = create(:geozone, name: 'Delete me!')
    debate = create(:debate, geozone: target_geozone)

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") { click_link 'Delete' }

    expect(page).to have_content('Delete me!')
    expect(debate.reload.geozone).to eq(target_geozone)
  end

  scenario 'Delete geozone with associated user' do
    target_geozone = create(:geozone, name: 'Delete me!')
    user = create(:user, geozone: target_geozone)

    visit admin_geozones_path

    within("#geozone_#{target_geozone.id}") { click_link 'Delete' }

    expect(page).to have_content('Delete me!')
    expect(user.reload.geozone).to eq(target_geozone)
  end
end
