require "rails_helper"

describe "SDG homepage configuration", :js do
  before do
    Setting["feature.sdg"] = true
    login_as(create(:sdg_manager).user)
  end

  describe "Show" do
    scenario "Visit the index" do
      visit sdg_management_root_path

      within("#side_menu") do
        click_link "SDG homepage"
      end

      expect(page).to have_title "SDG content - Homepage configuration"
    end
  end
end
