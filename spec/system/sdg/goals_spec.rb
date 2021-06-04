require "rails_helper"

describe "SDG Goals" do
  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.proposals"] = true
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

    scenario "has cards for phases" do
      create(:widget_card, cardable: SDG::Phase["planning"], title: "Planning card")

      visit sdg_goals_path

      within "#sdg_phase_planning" do
        expect(page).to have_css "header", exact_text: "Planning"
        expect(page).to have_content "PLANNING CARD"
      end
    end
  end

  describe "Show" do
    before do
      goal = SDG::Goal[15]

      create(:debate, title: "Solar panels", sdg_goals: [SDG::Goal[7]])
      create(:debate, title: "Hunting ground", sdg_goals: [goal])
      create(:proposal, title: "Animal farm", sdg_goals: [goal])
      create(:proposal, title: "Sea farm", sdg_goals: [SDG::Goal[14]])
      create(:legislation_process, title: "Bullfighting regulations", sdg_goals: [goal])
      create(:legislation_process, title: "Tax regulations", sdg_goals: [SDG::Goal[10]])
    end

    scenario "shows the SDG and its related content" do
      visit sdg_goal_path(15)

      within(".sdg-goal header") { expect(page).to have_content "15\nLIFE ON\nLAND" }

      within ".feed-proposals" do
        expect(page).to have_content "Animal farm"
        expect(page).not_to have_content "Sea farm"
      end

      within ".feed-debates" do
        expect(page).to have_content "Hunting ground"
        expect(page).not_to have_content "Solar panels"
      end

      within ".feed-processes" do
        expect(page).to have_content "BULLFIGHTING REGULATIONS"
        expect(page).not_to have_content "TAX REGULATIONS"
      end
    end

    scenario "has links to debates and proposals filtered by goal" do
      visit sdg_goal_path(15)

      click_link "See all debates"

      within "#debates" do
        expect(page).to have_content "Hunting ground"
        expect(page).not_to have_content "Solar panels"
      end

      within "#advanced_search_form" do
        expect(page).to have_select "By SDG", selected: "15. Life on Land"
      end

      go_back

      click_link "See all proposals"

      within "#proposals" do
        expect(page).to have_content "Animal farm"
        expect(page).not_to have_content "Sea farm"
      end

      within "#advanced_search_form" do
        expect(page).to have_select "By SDG", selected: "15. Life on Land"
      end
    end

    scenario "has buttons to read more and read less for long description" do
      visit sdg_goal_path(15)

      expect(page).to have_button "Read more about Life on Land"
      expect(page).to have_button "Read less about Life on Land", visible: :hidden

      click_button "Read more about Life on Land"

      expect(page).to have_button "Read more about Life on Land", visible: :hidden
      expect(page).to have_button "Read less about Life on Land"
    end

    scenario "has tab target section" do
      create(:sdg_local_target, code: "15.1.1", title: "SDG local target sample text")
      visit sdg_goal_path(15)

      within ".sdg-goal-targets" do
        expect(page).to have_content "Targets"
        expect(page).to have_content "Local targets"
      end

      within ".tabs-content" do
        expect(page).to have_content "15.1 By 2020, ensure the conservation, restoration and sustainable"
        expect(page).not_to have_content "15.1.1 SDG local target sample text"
      end

      click_link "Local targets"

      within ".tabs-content" do
        expect(page).to have_content "15.1.1 SDG local target sample text"
        expect(page).not_to have_content "15.1 By 2020, ensure the conservation, restoration and sustainable"
      end
    end
  end

  describe "Help" do
    scenario "shows all SDGs targets" do
      create(:sdg_local_target, code: "15.1.1", title: "SDG local target sample text")
      visit sdg_help_path

      expect(page).to have_content "You can align your contributions to the community"
      expect(page).to have_css "h2", exact_text: "1. No Poverty"
      expect(page).to have_content "End poverty in all its forms, everywhere."
      expect(page).to have_content "1.1 By 2030, eradicate extreme poverty for all people everywhere"

      click_link "7. Affordable and Clean Energy"

      expect(page).not_to have_css "h2", exact_text: "1. No Poverty"
      expect(page).to have_css "h2", exact_text: "7. Affordable and Clean Energy"
      expect(page).to have_content "Ensure access to affordable, reliable, sustainable and modern energy."
      expect(page).to have_content "7.1 By 2030, ensure universal access to affordable"

      click_link "15. Life on Land"

      expect(page).to have_css "h2", exact_text: "15. Life on Land"
      expect(page).to have_content "Sustainably manage forests, combat desertification, halt and reverse"
      expect(page).to have_content "15.1 By 2020, ensure the conservation, restoration and sustainable use"

      click_link "Local targets"

      expect(page).not_to have_content "15.1 By 2020, ensure the conservation, restoration and sustainable use"
      expect(page).to have_content "SDG local target sample text"
    end
  end
end
