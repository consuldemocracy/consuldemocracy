require 'rails_helper'

feature 'Admin settings' do

  background do
    @setting1 = create(:setting)
    @setting2 = create(:setting)
    @setting3 = create(:setting)
    login_as(create(:administrator).user)
  end

  scenario 'Index' do
    visit admin_settings_path

    expect(page).to have_content @setting1.key
    expect(page).to have_content @setting2.key
    expect(page).to have_content @setting3.key
  end

  scenario 'Update' do
    visit admin_settings_path

    within("#edit_setting_#{@setting2.id}") do
      fill_in "setting_#{@setting2.id}", with: 'Super Users of level 2'
      click_button 'Update'
    end

    expect(page).to have_content 'Value updated'
  end

  describe "Update map" do

    scenario "Should not be able when map feature deactivated" do
      Setting['feature.map'] = false
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#map-tab").click

      expect(page).not_to have_css("#admin-map")
    end

    scenario "Should be able when map feature activated" do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#map-tab").click

      expect(page).to have_css("#admin-map")
    end

    scenario "Should show successful notice" do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path

      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should display marker by default", :js do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path

      expect(find("#latitude", visible: false).value).to eq "51.48"
      expect(find("#longitude", visible: false).value).to eq "0.0"
    end

    scenario "Should update marker", :js do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#map-tab").click
      find("#admin-map").click
      within "#map-form" do
        click_on "Update"
      end

      expect(find("#latitude", visible: false).value).not_to eq "51.48"
      expect(page).to have_content "Map configuration updated succesfully"
    end

  end

  describe "Skip verification" do

    scenario "deactivate skip verification", :js do
      Setting["feature.user.skip_verification"] = 'true'
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_settings_path
      find("#features-tab").click

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "activate skip verification", :js do
      Setting["feature.user.skip_verification"] = nil
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_settings_path
      find("#features-tab").click

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content 'Value updated'

      Setting["feature.user.skip_verification"] = nil
    end

  end

  describe "Update documentable resource settings", :js do

    scenario "Should be able to update the maximum number of documents for proposals" do
      Setting["documents_proposal_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_proposal_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "Should be able to update the maximum number of documents for budget investment" do
      Setting["documents_budget_investment_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_budget_investment_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "Should be able to update the maximum number of documents for budget investment milestone" do
      Setting["documents_budget_investment_milestone_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_budget_investment_milestone_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "Should be able to update the maximum number of documents for legislation process milestone" do
      Setting["documents_legislation_process_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_legislation_process_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "Should be able to update the maximum number of documents for legislation proposal milestone" do
      Setting["documents_legislation_proposal_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_legislation_proposal_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

    scenario "Should be able to update the maximum number of documents for poll question answer" do
      Setting["documents_poll_question_answer_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_poll_question_answer_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '5'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
    end

  end



end
