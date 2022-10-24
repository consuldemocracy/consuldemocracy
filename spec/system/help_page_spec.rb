require "rails_helper"

describe "Help page" do
  context "Index" do
    scenario "Help menu and page is visible if feature is enabled" do
      Setting["feature.help_page"] = true
      Setting["org_name"] = "CONSUL"

      visit root_path

      expect(page).to have_link "Help"

      within("#navigation_bar") do
        click_link "Help"
      end

      expect(page).to have_content("CONSUL is a platform for citizen participation")
    end

    scenario "Help menu and page is hidden if feature is disabled" do
      Setting["feature.help_page"] = nil

      visit root_path

      expect(page).not_to have_link "Help"
    end
  end

  scenario "renders the default image for locales with no images" do
    Setting["feature.help_page"] = true

    visit help_path(locale: :de)

    within("#proposals") { expect(page).to have_css "img" }
  end

  scenario "renders the SDG help page link when the feature is enabled" do
    Setting["feature.help_page"] = true
    Setting["feature.sdg"] = true

    visit root_path
    within("#navigation_bar") do
      click_link "Help"
    end

    expect(page).to have_link "Sustainable Development Goals help", href: sdg_help_path
  end

  scenario "does not render the SDG help page link when the feature is disabled" do
    Setting["feature.sdg"] = nil

    visit root_path
    within("#navigation_bar") do
      click_link "Help"
    end

    expect(page).not_to have_link "Sustainable Development Goals help"
  end

  scenario "renders the legislation section link when the process is enabled" do
    Setting["feature.help_page"] = true
    Setting["process.legislation"] = true

    visit page_path("help")

    expect(page).to have_link "Processes", href: "#processes"
  end

  scenario "does not render the legislation section link when the process is disabled" do
    Setting["feature.help_page"] = true
    Setting["process.legislation"] = nil

    visit page_path("help")

    expect(page).not_to have_link "Processes"
  end
end
