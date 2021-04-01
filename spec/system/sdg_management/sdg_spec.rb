require "rails_helper"

describe "SDG Management" do
  before { login_as(create(:administrator).user) }

  context "SDG feature flag is enabled" do
    before { Setting["feature.sdg"] = true }

    scenario "shows the SDG content link" do
      visit root_path
      click_link "Menu"

      expect(page).to have_link "SDG content"
    end
  end

  context "SDG feature is disabled" do
    before { Setting["feature.sdg"] = false }

    scenario "does not show the SDG Content link" do
      visit root_path
      click_link "Menu"

      expect(page).not_to have_link "SDG content"
    end
  end
end
