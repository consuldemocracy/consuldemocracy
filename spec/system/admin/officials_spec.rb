require "rails_helper"

describe "Admin officials", :admin do
  let!(:citizen) { create(:user, username: "Citizen Kane") }
  let!(:official) { create(:user, official_position: "Mayor", official_level: 5) }

  scenario "Index" do
    visit admin_officials_path

    expect(page).to have_content official.name
    expect(page).not_to have_content citizen.name
    expect(page).to have_content official.official_position
    expect(page).to have_content official.official_level
  end

  scenario "Edit an official" do
    visit admin_officials_path
    click_link "Edit official"

    expect(page).to have_current_path(edit_admin_official_path(official))

    expect(page).not_to have_content citizen.name
    expect(page).to have_content official.name
    expect(page).to have_content official.email

    fill_in "user_official_position", with: "School Teacher"
    select "3", from: "user_official_level", exact: false
    click_button "Update User"

    expect(page).to have_content "Details of official saved"

    visit admin_officials_path

    expect(page).to have_content official.name
    expect(page).to have_content "School Teacher"
    expect(page).to have_content "3"
  end

  scenario "Create an official" do
    visit admin_officials_path
    fill_in "search", with: citizen.email
    click_button "Search"

    expect(page).to have_current_path(search_admin_officials_path, ignore_query: true)
    expect(page).not_to have_content official.name

    click_link citizen.name

    fill_in "user_official_position", with: "Hospital manager"
    select "4", from: "user_official_level", exact: false
    click_button "Update User"

    expect(page).to have_content "Details of official saved"

    visit admin_officials_path

    expect(page).to have_content official.name
    expect(page).to have_content citizen.name
    expect(page).to have_content "Hospital manager"
    expect(page).to have_content "4"
  end

  scenario "Destroy" do
    visit edit_admin_official_path(official)

    click_link 'Remove "Official" status'

    expect(page).to have_content "Details saved: the user is no longer an official"
    expect(page).to have_current_path(admin_officials_path, ignore_query: true)
    expect(page).not_to have_content citizen.name
    expect(page).not_to have_content official.name
  end
end
