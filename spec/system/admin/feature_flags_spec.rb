require "rails_helper"

describe "Admin feature flags", :admin do
  before do
    Setting["process.budgets"] = true
  end

  scenario "Enabled features are listed on menu" do
    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Debates"
    end
  end

  scenario "Disable a participatory process", :show_exceptions do
    budget = create(:budget)

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("tr", text: "Participatory budgeting") do
      click_button "Yes"

      expect(page).to have_button "No"
    end

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    visit budget_path(budget)

    expect(page).to have_title "Forbidden"

    visit admin_budgets_path

    expect(page).to have_current_path admin_budgets_path
    expect(page).to have_title "Forbidden"
  end

  scenario "Enable a disabled participatory process" do
    Setting["process.budgets"] = nil

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("tr", text: "Participatory budgeting") do
      click_button "No"

      expect(page).to have_button "Yes"
    end

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
    end
  end

  scenario "Disable a feature" do
    visit admin_settings_path
    click_link "Features"

    within("tr", text: "Twitter login") do
      click_button "Yes"

      expect(page).to have_button "No"
      expect(page).not_to have_button "Yes"
    end
  end

  scenario "Enable a disabled feature" do
    visit admin_settings_path
    click_link "Features"

    within("tr", text: "Proposals and budget investments geolocation") do
      click_button "No"

      expect(page).to have_button "Yes"
      expect(page).not_to have_button "No"
    end
  end
end
