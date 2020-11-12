require "rails_helper"

describe "Goals", :js do
  before { login_as(create(:administrator).user) }

  describe "Index" do
    scenario "Visit the index" do
      create(:sdg_goal, title: "No more heroes")

      visit admin_root_path

      within("#side_menu") do
        click_link "SDG content"
        click_link "Goals"
      end

      expect(page).to have_title "Administration - Goals"

      within("tr", text: "No more heroes") do
        expect(page).to have_link "Edit"
      end
    end
  end

  describe "Edit" do
    scenario "Update a record" do
      create(:sdg_goal, title: "No more heroes")

      visit admin_sdg_goals_path

      within("tr", text: "No more heroes") { click_link "Edit" }

      fill_in "Title", with: "More heroes"
      click_button "Update goal"

      expect(page).to have_content "Goal updated successfully"
      expect(page).to have_css "tr", text: "More heroes"
      expect(page).not_to have_css "tr", text: "No more heroes"
    end
  end
end
