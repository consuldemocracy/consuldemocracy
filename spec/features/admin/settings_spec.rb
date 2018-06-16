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

    scenario "Admin should be able to update the maximum number of documents for proposals" do
      Setting["documents_proposal_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_proposal_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '22'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "22"
    end

    scenario "User visits new proposal page and should see updated maximum number of documents" do
      @user  = create(:user, username: 'Jose Luis Balbin')
      login_as(@user.username)

      visit new_proposal_path
      expect(page).to have_content "22"
    end

    scenario "Admin should be able to update the maximum file size for proposals" do
      Setting["documents_proposal_max_file_size"] = '3'
      setting = Setting.where(key:"documents_proposal_max_file_size").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '23'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "23"
    end

    scenario "Admin should be able to update the accepted content types for proposals" do
      Setting["documents_proposal_accepted_content_types"] = "application/pdf"
      setting = Setting.where(key:"documents_proposal_accepted_content_types").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: "json"
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "json"
    end

    scenario "Admin should be able to update the maximum number of documents for budget investment" do
      Setting["documents_budget_investment_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_budget_investment_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '77'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "77"
    end

    scenario "User visits new buget investment page and should see updated maximum number of documents" do
      @user  = create(:user, username: 'Jose Luis Balbin')
      login_as(@user.username)

      visit create_investments_management_budgets_path
      expect(page).to have_content "77"
    end

    scenario "Admin should be able to update the maximum number of documents for budget investment milestone" do
      Setting["documents_budget_investment_milestone_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_budget_investment_milestone_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '18'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "18"
    end

    scenario "Admin should be able to update the maximum number of documents for legislation process milestone" do
      Setting["documents_legislation_process_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_legislation_process_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '9'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "9"
    end

    scenario "Admin should be able to update the maximum number of documents for legislation proposal milestone" do
      Setting["documents_legislation_proposal_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_legislation_proposal_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '10'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "10"

    end

    scenario "Admin should be able to update the maximum number of documents for poll question answer" do
      Setting["documents_poll_question_answer_max_documents_allowed"] = '3'
      setting = Setting.where(key:"documents_poll_question_answer_max_documents_allowed").first

      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{setting.id}") do
        fill_in "setting_#{setting.id}", with: '11'
        click_button 'Update'
      end

      expect(page).to have_content 'Value updated'
      expect(page).to have_content "11"
    end

  end


end
