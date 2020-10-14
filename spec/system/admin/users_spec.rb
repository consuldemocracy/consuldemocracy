require "rails_helper"

describe "Admin users" do
  let(:admin) { create(:administrator) }
  let!(:user) { create(:user, username: "Jose Luis Balbin") }

  before do
    login_as(admin.user)
    visit admin_users_path
  end

  scenario "Index" do
    expect(page).to have_link user.name
    expect(page).to have_content user.email
    expect(page).to have_content admin.name
    expect(page).to have_content admin.email
  end

  scenario "The username links to their public profile" do
    click_link user.name

    expect(page).to have_current_path(user_path(user))
  end

  scenario "Show active or erased users using filters" do
    erased_user = create(:user, username: "Erased")
    erased_user.erase("I don't like this site.")

    visit admin_users_path

    expect(page).not_to have_link("#{erased_user.id}", href: user_path(erased_user))
    expect(page).to have_link("Erased")

    click_link "Erased"

    expect(page).to have_link("Active")
    expect(page).to have_link("#{erased_user.id}", href: user_path(erased_user))
    expect(page).to have_content "I don't like this site."
    expect(page).to have_content("Erased")

    fill_in :search, with: "Erased"
    click_button "Search"

    expect(page).to have_content "There are no users."
  end

  scenario "Search" do
    fill_in :search, with: "Luis"
    click_button "Search"

    expect(page).to have_content user.name
    expect(page).to have_content user.email
    expect(page).not_to have_content admin.name
    expect(page).not_to have_content admin.email
  end
end
