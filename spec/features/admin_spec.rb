require 'rails_helper'

feature 'Admin' do
  let(:user) { create(:user) }

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(root_path)
    expect(page).to have_content "not authorized"
  end

  scenario 'Access as a moderator is not authorized' do
    create(:moderator, user: user)

    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(root_path)
    expect(page).to have_content "not authorized"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)

    login_as(user)
    visit admin_root_path

    expect(current_path).to eq(admin_root_path)
    expect(page).to_not have_content "not authorized"
  end

  scenario "Admin access links" do
    create(:administrator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link('Administration')
    expect(page).to_not have_link('Moderator')
  end

  scenario "Moderation access links" do
    create(:moderator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link('Moderation')
    expect(page).to_not have_link('Administration')
  end

  scenario 'Admin dashboard' do
    create(:administrator, user: user)

    login_as(user)
    visit root_path

    click_link 'Administration'

    expect(current_path).to eq(admin_root_path)
    expect(page).to have_css('#admin_menu')
    expect(page).to_not have_css('#moderation_menu')
  end

  scenario 'Moderation dashboard' do
    create(:moderator, user: user)

    login_as(user)
    visit root_path

    click_link 'Moderation'

    expect(current_path).to eq(moderation_root_path)
    expect(page).to have_css('#moderation_menu')
    expect(page).to_not have_css('#admin_menu')
  end

end
