require "rails_helper"

describe "Account" do
  let(:user) { create(:user, username: "Manuela Colau") }

  before do
    login_as(user)
  end

  scenario "Show" do
    visit root_path

    click_link "My account"

    expect(page).to have_current_path(account_path, ignore_query: true)

    within(".account") do
      expect(page).to have_selector("input[value='Manuela Colau']")
      expect(page).to have_selector(avatar("Manuela Colau"), count: 1)
    end
  end

  scenario "Show organization" do
    create(:organization, user: user, name: "Manuela Corp")

    visit account_path

    within(".account") do
      expect(page).to have_selector("input[value='Manuela Corp']")
      expect(page).not_to have_selector("input[value='Manuela Colau']")

      expect(page).to have_selector(avatar("Manuela Corp"), count: 1)
    end
  end

  scenario "Can access from header avatar" do
    visit root_path

    within(".account-menu") do
      expect(page).to have_selector(avatar("Manuela Colau"), count: 1)
      find(".avatar-image").click
    end

    expect(page).to have_current_path(account_path, ignore_query: true)

    within(".account") do
      expect(page).to have_selector("input[value=\"Manuela Colau\"]")
      expect(page).to have_selector(avatar("Manuela Colau"), count: 1)
    end
  end
end
