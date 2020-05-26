require "rails_helper"

describe "Admin moderators" do
  let!(:user)      { create(:user, username: "Jose Luis Balbin") }
  let!(:moderator) { create(:moderator) }

  before do
    login_as(create(:administrator).user)
    visit admin_moderators_path
  end

  scenario "Index" do
    expect(page).to have_content moderator.name
    expect(page).to have_content moderator.email
    expect(page).not_to have_content user.name
  end

  scenario "Create Moderator", :js do
    fill_in "name_or_email", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    within("#moderators") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete Moderator" do
    click_link "Delete"

    within("#moderators") do
      expect(page).not_to have_content moderator.name
    end
  end

  context "Search" do
    let(:user)        { create(:user, username: "Elizabeth Bathory", email: "elizabeth@bathory.com") }
    let(:user2)       { create(:user, username: "Ada Lovelace", email: "ada@lovelace.com") }
    let!(:moderator1) { create(:moderator, user: user) }
    let!(:moderator2) { create(:moderator, user: user2) }

    before do
      visit admin_moderators_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(moderator1.name)
      expect(page).to have_content(moderator2.name)

      fill_in "name_or_email", with: " "
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(moderator1.name)
      expect(page).not_to have_content(moderator2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(moderator1.name)
      expect(page).to have_content(moderator2.name)

      fill_in "name_or_email", with: "Eliz"
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_content(moderator1.name)
      expect(page).not_to have_content(moderator2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(moderator1.email)
      expect(page).to have_content(moderator2.email)

      fill_in "name_or_email", with: moderator2.email
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_content(moderator2.email)
      expect(page).not_to have_content(moderator1.email)
    end
  end
end
