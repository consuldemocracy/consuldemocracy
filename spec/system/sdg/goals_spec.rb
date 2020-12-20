require "rails_helper"

describe "SDG Goals", :js do
  before do
    Setting["feature.sdg"] = true
  end

  describe "SDG navigation link" do
    scenario "is not present when the feature is disabled" do
      Setting["feature.sdg"] = false

      visit root_path

      within("#navigation_bar") { expect(page).not_to have_link "SDG" }
    end

    scenario "routes to the goals index" do
      visit root_path
      within("#navigation_bar") { click_link "SDG" }

      expect(page).to have_current_path sdg_goals_path
    end
  end

  describe "Index" do
    scenario "has links to SDGs" do
      visit sdg_goals_path

      click_link "7. Affordable and Clean Energy"

      expect(page).to have_current_path sdg_goal_path(7)
    end
  end

  describe "Show" do
    scenario "shows the SDG and its related content" do
      goal = SDG::Goal[15]

      create(:debate, title: "Solar panels", sdg_goals: [SDG::Goal[7]])
      create(:debate, title: "Hunting ground", sdg_goals: [goal])
      create(:proposal, title: "Animal farm", sdg_goals: [goal])
      create(:proposal, title: "Sea farm", sdg_goals: [SDG::Goal[14]])

      visit sdg_goal_path(15)

      within(".sdg-goal header") { expect(page).to have_content "Life on Land" }

      within ".feed-proposals" do
        expect(page).to have_content "Animal farm"
        expect(page).not_to have_content "Sea farm"
      end

      within ".feed-debates" do
        expect(page).to have_content "Hunting ground"
        expect(page).not_to have_content "Solar panels"
      end
    end
  end
end
