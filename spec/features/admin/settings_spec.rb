require "rails_helper"

describe "Admin settings" do

  before do
    @setting1 = create(:setting)
    @setting2 = create(:setting)
    @setting3 = create(:setting)
    login_as(create(:administrator).user)
  end

  scenario "Index" do
    visit admin_settings_path

    expect(page).to have_content @setting1.key
    expect(page).to have_content @setting2.key
    expect(page).to have_content @setting3.key
  end

  scenario "Update" do
    visit admin_settings_path

    within("#edit_setting_#{@setting2.id}") do
      fill_in "setting_#{@setting2.id}", with: "Super Users of level 2"
      click_button "Update"
    end

    expect(page).to have_content "Value updated"
  end

  describe "Update map" do

    scenario "Should not be able when map feature deactivated" do
      Setting["feature.map"] = false
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#map-tab").click

      expect(page).to have_content 'To show the map to users you must enable ' \
                                   '"Proposals and budget investments geolocation" ' \
                                   'on "Features" tab.'
      expect(page).not_to have_css("#admin-map")
    end

    scenario "Should be able when map feature activated" do
      Setting["feature.map"] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#map-tab").click

      expect(page).to have_css("#admin-map")
      expect(page).not_to have_content 'To show the map to users you must enable ' \
                                       '"Proposals and budget investments geolocation" ' \
                                       'on "Features" tab.'
    end

    scenario "Should show successful notice" do
      Setting["feature.map"] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path

      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should display marker by default", :js do
      Setting["feature.map"] = true
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path

      expect(find("#latitude", visible: false).value).to eq "51.48"
      expect(find("#longitude", visible: false).value).to eq "0.0"
    end

    scenario "Should update marker", :js do
      Setting["feature.map"] = true
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

  describe "Update content types" do

    scenario "stores the correct mime types" do
      setting = Setting.create(key: "upload.images.content_types", value: "image/png")
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#images-and-documents-tab").click

      within "#edit_setting_#{setting.id}" do
        expect(find("#png")).to be_checked
        expect(find("#jpg")).not_to be_checked
        expect(find("#gif")).not_to be_checked

        check "gif"

        click_button "Update"
      end

      expect(page).to have_content "Value updated"
      expect(Setting["upload.images.content_types"]).to include "image/png"
      expect(Setting["upload.images.content_types"]).to include "image/gif"

      visit admin_settings_path(anchor: "tab-images-and-documents")

      within "#edit_setting_#{setting.id}" do
        expect(find("#png")).to be_checked
        expect(find("#gif")).to be_checked
        expect(find("#jpg")).not_to be_checked
      end
    end

  end

  describe "Update Remote Census Configuration" do

    before do
      Setting["feature.remote_census"] = true
    end

    after do
      Setting["feature.remote_census"] = nil
    end

    scenario "Should not be able when remote census feature deactivated" do
      Setting["feature.remote_census"] = nil
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#remote-census-tab").click

      expect(page).to have_content 'To configure remote census (SOAP) you must enable ' \
                                   '"Configure connection to remote census (SOAP)" ' \
                                   'on "Features" tab.'
    end

    scenario "Should be able when remote census feature activated" do
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#remote-census-tab").click

      expect(page).to have_content("General Information")
      expect(page).to have_content("Request Data")
      expect(page).to have_content("Response Data")
      expect(page).not_to have_content 'To configure remote census (SOAP) you must enable ' \
                                       '"Configure connection to remote census (SOAP)" ' \
                                       'on "Features" tab.'
    end

  end

  describe "Should redirect to same tab after update setting" do

    context "remote census" do

      before do
        Setting["feature.remote_census"] = true
      end

      after do
        Setting["feature.remote_census"] = nil
      end

      scenario "On #tab-remote-census-configuration", :js do
        remote_census_setting = create(:setting, key: "remote_census.general.whatever")
        admin = create(:administrator).user
        login_as(admin)
        visit admin_settings_path
        find("#remote-census-tab").click

        within("#edit_setting_#{remote_census_setting.id}") do
          fill_in "setting_#{remote_census_setting.id}", with: "New value"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-remote-census-configuration.is-active")
      end
    end

    scenario "On #tab-configuration", :js do
      configuration_setting = Setting.create(key: "whatever")
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#tab-configuration").click

      within("#edit_setting_#{configuration_setting.id}") do
        fill_in "setting_#{configuration_setting.id}", with: "New value"
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-configuration.is-active")
    end

    context "map configuration" do

      before do
        Setting["feature.map"] = true
      end

      after do
        Setting["feature.map"] = nil
      end

      scenario "On #tab-map-configuration", :js do
        map_setting = Setting.create(key: "map.whatever")
        admin = create(:administrator).user
        login_as(admin)
        visit admin_settings_path
        find("#map-tab").click

        within("#edit_setting_#{map_setting.id}") do
          fill_in "setting_#{map_setting.id}", with: "New value"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-map-configuration.is-active")
      end
    end

    scenario "On #tab-proposals", :js do
      proposal_dashboard_setting = Setting.create(key: "proposals.whatever")
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#proposals-tab").click

      within("#edit_setting_#{proposal_dashboard_setting.id}") do
        fill_in "setting_#{proposal_dashboard_setting.id}", with: "New value"
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-proposals.is-active")
    end

    scenario "On #tab-participation-processes", :js do
      process_setting = Setting.create(key: "process.whatever")
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#participation-processes-tab").click

      accept_alert do
        find("#edit_setting_#{process_setting.id} .button").click
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-participation-processes.is-active")
    end

    scenario "On #tab-feature-flags", :js do
      feature_setting = Setting.create(key: "feature.whatever")
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path
      find("#features-tab").click

      accept_alert do
        find("#edit_setting_#{feature_setting.id} .button").click
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-feature-flags.is-active")
    end
  end

  describe "Skip verification" do

    scenario "deactivate skip verification", :js do
      Setting["feature.user.skip_verification"] = "true"
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_settings_path
      find("#features-tab").click

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content "Value updated"
    end

    scenario "activate skip verification", :js do
      Setting["feature.user.skip_verification"] = nil
      setting = Setting.where(key: "feature.user.skip_verification").first

      visit admin_settings_path
      find("#features-tab").click

      accept_alert do
        find("#edit_setting_#{setting.id} .button").click
      end

      expect(page).to have_content "Value updated"

      Setting["feature.user.skip_verification"] = nil
    end

  end

end
