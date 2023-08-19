require "rails_helper"

describe "Management" do
  let(:user) { create(:user) }

  scenario "Does not show the admin menu when managing users having the admin menu" do
    create(:manager, user: user)
    create(:moderator, user: create(:user, :in_census, document_number: "12345678M"))

    login_as(user)
    visit management_sign_in_path
    click_link "Select user"
    fill_in "Document number", with: "12345678M"
    click_button "Check document"

    expect(page).to have_content "This user account is already verified"
    expect(page).not_to have_content "You don't have new notifications"
    expect(page).not_to have_content "My content"
    expect(page).not_to have_content "My account"
    expect(page).not_to have_content "Sign out"
  end
end
