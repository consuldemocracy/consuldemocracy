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
