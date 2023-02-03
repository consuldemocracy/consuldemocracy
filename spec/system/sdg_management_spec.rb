require "rails_helper"

describe "SDGManagement" do
  let(:user) { create(:user) }

  before { Setting["feature.sdg"] = true }

  context "Access" do
    scenario "Access as regular user is not authorized" do
      login_as(user)

      visit sdg_management_root_path

      expect(page).not_to have_current_path(sdg_management_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as manager is not authorized" do
      create(:manager, user: user)
      login_as(user)

      visit sdg_management_root_path

      expect(page).not_to have_current_path(sdg_management_root_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to access this page"
    end

    scenario "Access as a sdg manager is authorized" do
      create(:sdg_manager, user: user)
      login_as(user)
      visit root_path

      click_on "Menu"
      click_on "SDG content"

      expect(page).to have_current_path(sdg_management_root_path)
      expect(page).to have_css ".sdg-content-menu"
      expect(page).not_to have_css "#valuation_menu"
      expect(page).not_to have_css "#admin_menu"
      expect(page).not_to have_css "#moderation_menu"
      expect(page).not_to have_content "You do not have permission to access this page"
    end
  end
end
