require "rails_helper"

describe "SDG Management" do
  before { login_as(create(:administrator).user) }

  context "SDG feature flag is enabled", :js do
    before { Setting["feature.sdg"] = true }

    scenario "shows the SDG content link" do
      visit root_path
      click_link "Menu"

      expect(page).to have_link "SDG content"
    end
  end

  context "SDG feature is disabled" do
    before { Setting["feature.sdg"] = false }

    scenario "does not show the SDG Content link", :js do
      visit root_path
      click_link "Menu"

      expect(page).not_to have_link "SDG content"
    end

    scenario "does not allow visits to the SDG content" do
      expect { visit sdg_management_root_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
