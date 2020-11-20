require "rails_helper"

describe "Admin feature flags", :admin do
  before do
    Setting["process.budgets"] = true
  end

  scenario "Enabled features are listed on menu" do
    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Hidden debates"
    end
  end

  scenario "Disable a participatory process" do
    setting = Setting.find_by(key: "process.budgets")
    budget = create(:budget)

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"
      click_button "Disable"
    end

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    expect { visit budget_path(budget) }.to raise_exception(FeatureFlags::FeatureDisabled)
    expect { visit admin_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario "Enable a disabled participatory process" do
    Setting["process.budgets"] = nil
    setting = Setting.find_by(key: "process.budgets")

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"
      click_button "Enable"
    end

    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
    end
  end

  scenario "Disable a feature" do
    setting = Setting.find_by(key: "feature.twitter_login")

    visit admin_settings_path

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"
      click_button "Disable"
    end

    expect(page).to have_content "Value updated"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"
    end
  end

  scenario "Enable a disabled feature" do
    setting = Setting.find_by(key: "feature.map")

    visit admin_settings_path

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"
      click_button "Enable"
    end

    expect(page).to have_content "Value updated"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"
    end
  end
end
