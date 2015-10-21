require 'rails_helper'

feature 'Admin' do
  let(:user) { create(:user) }

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Moderation")
    visit moderation_root_path

    expect(current_path).not_to eq(moderation_root_path)
    expect(current_path).to eq(proposals_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a moderator is authorized' do
    create(:moderator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link("Moderation")
    click_on "Moderation"

    expect(current_path).to eq(moderation_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)

    login_as(user)
    visit root_path

    expect(page).to have_link("Moderation")
    click_on "Moderation"

    expect(current_path).to eq(moderation_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

end
