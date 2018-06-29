require 'rails_helper'

feature 'Communication' do
  let(:user) { create(:user) }

  before do
    Setting['feature.cdj_aude'] = true
  end

  after do
    Setting['feature.cdj_aude'] = nil
  end

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Communication")
    visit communication_root_path

    expect(page).not_to have_current_path(communication_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as valuator is not authorized' do
    create(:valuator, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Communication")
    visit communication_root_path

    expect(page).not_to have_current_path(communication_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as manager is not authorized' do
    create(:manager, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Communication")
    visit communication_root_path

    expect(page).not_to have_current_path(communication_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as poll officer is not authorized' do
    create(:poll_officer, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Communication")
    visit communication_root_path

    expect(page).not_to have_current_path(communication_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a moderator is not authorized' do
    create(:moderator, user: user)

    login_as(user)
    visit root_path

    expect(page).not_to have_link("Communication")
    visit communication_root_path

    expect(page).not_to have_current_path(communication_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as an animator is authorized' do
    create(:animator, user: user)

    login_as(user)
    visit root_path
    expect(page).to have_link("Communication")
    click_on('Communication', match: :first)

    expect(page).to have_current_path(communication_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link("Communication")
    click_on('Communication', match: :first)

    expect(page).to have_current_path(communication_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

end