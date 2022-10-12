require "rails_helper"

describe "AUE Goals" do
  before do
    Setting["feature.aue"] = true
  end

  before(:each) do
    I18n.locale = :es
  end

  describe "AUE navigation link" do
    scenario "is not present when the feature is disabled" do
      Setting["feature.aue"] = false

      visit root_path

      within("#navigation_bar") { expect(page).not_to have_link "AUE" }
    end

    scenario "routes to the goals index" do
      visit root_path
      within("#navigation_bar") { click_link "AUE" }

      expect(page).to have_current_path aue_goals_path
    end
  end

  describe "Index" do
    scenario "has links to AUEs" do
      visit aue_goals_path(locale: :es)

      click_link "Objetivo Estratégico 3: Prevenir y reducir los impactos del cambio climático y mejorar la resiliencia."

      expect(page).to have_current_path aue_goal_path(3)
    end
  end

end
