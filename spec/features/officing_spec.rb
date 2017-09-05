require 'rails_helper'

feature 'Poll Officing' do
  let(:user) { create(:user) }

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Polling officers")
    visit officing_root_path

    expect(current_path).not_to eq(officing_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as moderator is not authorized' do
    create(:moderator, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Polling officers")
    visit officing_root_path

    expect(current_path).not_to eq(officing_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as manager is not authorized' do
    create(:manager, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Polling officers")
    visit officing_root_path

    expect(current_path).not_to eq(officing_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a valuator is not authorized' do
    create(:valuator, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Polling officers")
    visit officing_root_path

    expect(current_path).not_to eq(officing_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as an poll officer is authorized' do
    create(:poll_officer, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    click_on "Polling officers"

    expect(current_path).to eq(officing_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    click_on "Polling officers"

    expect(current_path).to eq(officing_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario "Poll officer access links" do
    create(:poll_officer, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    expect(page).to_not have_link('Valuation')
    expect(page).to_not have_link('Administration')
    expect(page).to_not have_link('Moderation')
  end

  scenario 'Officing dashboard' do
    create(:poll_officer, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    click_link 'Polling officers'

    expect(current_path).to eq(officing_root_path)
    expect(page).to have_css('#officing_menu')
    expect(page).to_not have_css('#valuation_menu')
    expect(page).to_not have_css('#admin_menu')
    expect(page).to_not have_css('#moderation_menu')
  end

end