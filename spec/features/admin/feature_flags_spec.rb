require "rails_helper"

feature "Admin feature flags" do

  background do
    Setting["feature.spending_proposals"] = true
    Setting["feature.spending_proposal_features.voting_allowed"] = true
    login_as(create(:administrator).user)
  end

  after do
    Setting["feature.spending_proposals"] = nil
    Setting["feature.spending_proposal_features.voting_allowed"] = nil
  end

  scenario "Enabled features are listed on menu" do
    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Spending proposals"
      expect(page).to have_link "Hidden debates"
    end
  end

  scenario "Disable a feature" do
    setting_id = Setting.find_by(key: "feature.spending_proposals").id

    visit admin_settings_path

    within("#edit_setting_#{setting_id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"
      click_button "Disable"
    end

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Budgets"
      expect(page).not_to have_link "Spending proposals"
    end

    expect{ visit spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    expect{ visit admin_spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario "Enable a disabled feature" do
    Setting["feature.spending_proposals"] = nil
    setting_id = Setting.find_by(key: "feature.spending_proposals").id

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Budgets"
      expect(page).not_to have_link "Spending proposals"
    end

    visit admin_settings_path

    within("#edit_setting_#{setting_id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"
      click_button "Enable"
    end

    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Spending proposals"
    end
  end

end
