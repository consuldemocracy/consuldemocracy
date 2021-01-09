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

    scenario "Create card" do
      visit sdg_management_homepage_path
      click_link "Create planning card"

      within(".translatable-fields") { fill_in "Title", with: "My planning card" }
      click_button "Create card"

      within(".planning-cards") do
        expect(page).to have_content "My planning card"
      end

      within(".sensitization-cards") do
        expect(page).to have_content "There are no cards for this phase"
      end
    end

    scenario "Update card" do
      create(:widget_card, cardable: SDG::Phase["monitoring"], title: "My monitoring card")

      visit sdg_management_homepage_path
      within(".monitoring-cards") { click_link "Edit" }

      within(".translatable-fields") { fill_in "Title", with: "Updated monitoring card" }
      click_button "Save card"

      within(".monitoring-cards") do
        expect(page).to have_css "tbody tr", count: 1
        expect(page).to have_content "Updated monitoring card"
        expect(page).not_to have_content "My monitoring card"
      end
    end
  end
end
