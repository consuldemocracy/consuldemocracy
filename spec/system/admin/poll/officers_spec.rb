require "rails_helper"

describe "Admin poll officers", :admin do
  let!(:user)    { create(:user, username: "Pedro Jose Garcia") }
  let!(:officer) { create(:poll_officer) }

  before do
    visit admin_officers_path
  end

  scenario "Index" do
    expect(page).to have_content officer.name
    expect(page).to have_content officer.email
    expect(page).not_to have_content user.name
  end

  scenario "Create" do
    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name

    click_button "Add"

    within("#officers") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete" do
    accept_confirm("Are you sure? This action will delete \"#{officer.name}\" and can't be undone.") do
      click_button "Delete position"
    end

    expect(page).not_to have_css "#officers"
  end
end
