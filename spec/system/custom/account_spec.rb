require "rails_helper"

describe "Account" do
  let(:user) { create(:user, username: "Manuela Colau") }

  before do
    login_as(user)
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
