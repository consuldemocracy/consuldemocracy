require "rails_helper"

describe "Admin settings", :admin do
  scenario "Index" do
    create(:setting, key: "super.users.first")
    create(:setting, key: "super.users.second")
    create(:setting, key: "super.users.third")

    visit admin_settings_path

    expect(page).to have_content "First"
    expect(page).to have_content "Second"
    expect(page).to have_content "Third"
  end

  scenario "Update" do
    create(:setting, key: "super.users.first")

    visit admin_settings_path

    within "tr", text: "First" do
      fill_in "First", with: "Super Users of level 1"
      click_button "Update"
    end

    expect(page).to have_content "Value updated"
  end

  describe "Map settings initialization" do
    before do
      Setting["feature.map"] = true
    end

    scenario "When `Map settings` tab content is hidden map should not be initialized" do
      visit admin_settings_path

      expect(page).not_to have_css("#admin-map.leaflet-container", visible: :all)
    end

    scenario "When `Map settings` tab content is shown map should be initialized" do
      visit admin_settings_path

      click_link "Map configuration"

      expect(page).to have_css("#admin-map.leaflet-container")
    end
  end

  describe "Update map" do
    scenario "Should not be able when map feature deactivated" do
      Setting["feature.map"] = false

      visit admin_settings_path
      click_link "Map configuration"

      expect(page).to have_content "To show the map to users you must enable " \
                                   '"Proposals and budget investments geolocation" ' \
                                   'on "Features" tab.'
      expect(page).not_to have_css("#admin-map")
    end

    scenario "Should be able when map feature activated" do
      Setting["feature.map"] = true

      visit admin_settings_path
      click_link "Map configuration"

      expect(page).to have_css("#admin-map")
      expect(page).not_to have_content "To show the map to users you must enable " \
                                       '"Proposals and budget investments geolocation" ' \
                                       'on "Features" tab.'
    end

    scenario "Should show successful notice" do
      Setting["feature.map"] = true

      visit admin_settings_path
      click_link "Map configuration"

      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should display marker by default" do
      Setting["feature.map"] = true

      visit admin_settings_path

      expect(find("#latitude", visible: :hidden).value).to eq "51.48"
      expect(find("#longitude", visible: :hidden).value).to eq "0.0"
    end

    scenario "Should update marker" do
      Setting["feature.map"] = true

      visit admin_settings_path
      click_link "Map configuration"
      find("#admin-map").click
      within "#map-form" do
        click_on "Update"
      end

      expect(find("#latitude", visible: :hidden).value).not_to eq "51.48"
      expect(page).to have_content "Map configuration updated succesfully"
    end
  end

  describe "Update content types" do
    scenario "stores the correct mime types" do
      Setting["uploads.images.content_types"] = "image/png"
      setting = Setting.find_by!(key: "uploads.images.content_types")

      visit admin_settings_path
      click_link "Images and documents"

      within "#edit_setting_#{setting.id}" do
        expect(find_field("PNG")).to be_checked
        expect(find_field("JPG")).not_to be_checked
        expect(find_field("GIF")).not_to be_checked

        check "GIF"

        click_button "Update"
      end

      expect(page).to have_content "Value updated"

      click_link "Images and documents"

      within "#edit_setting_#{setting.id}" do
        expect(find_field("PNG")).to be_checked
        expect(find_field("GIF")).to be_checked
        expect(find_field("JPG")).not_to be_checked
      end
    end
  end

  describe "Update Remote Census Configuration" do
    before do
      Setting["feature.remote_census"] = true
    end

    scenario "Should not be able when remote census feature deactivated" do
      Setting["feature.remote_census"] = nil
      visit admin_settings_path
      find("#remote-census-tab").click

      expect(page).to have_content "To configure remote census (SOAP) you must enable " \
                                   '"Configure connection to remote census (SOAP)" ' \
                                   'on "Features" tab.'
    end

    scenario "Should be able when remote census feature activated" do
      visit admin_settings_path
      find("#remote-census-tab").click

      expect(page).to have_content("General Information")
      expect(page).to have_content("Request Data")
      expect(page).to have_content("Response Data")
      expect(page).not_to have_content "To configure remote census (SOAP) you must enable " \
                                       '"Configure connection to remote census (SOAP)" ' \
                                       'on "Features" tab.'
    end
  end

  describe "Should redirect to same tab after update setting" do
    context "remote census" do
      before do
        Setting["feature.remote_census"] = true
      end

      scenario "On #tab-remote-census-configuration" do
        create(:setting, key: "remote_census.general.whatever")

        visit admin_settings_path
        find("#remote-census-tab").click

        within "tr", text: "Whatever" do
          fill_in "Whatever", with: "New value"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-remote-census-configuration.is-active")
      end
    end

    scenario "On #tab-configuration" do
      Setting.create!(key: "whatever")

      visit admin_settings_path
      find("#tab-configuration").click

      within "tr", text: "Whatever" do
        fill_in "Whatever", with: "New value"
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-configuration.is-active")
    end

    context "map configuration" do
      before do
        Setting["feature.map"] = true
      end

      scenario "On #tab-map-configuration" do
        Setting.create!(key: "map.whatever")

        visit admin_settings_path
        click_link "Map configuration"

        within "tr", text: "Whatever" do
          fill_in "Whatever", with: "New value"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-map-configuration.is-active")
      end
    end

    scenario "On #tab-proposals" do
      Setting.create!(key: "proposals.whatever")

      visit admin_settings_path
      find("#proposals-tab").click

      within "tr", text: "Whatever" do
        fill_in "Whatever", with: "New value"
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-proposals.is-active")
    end

    scenario "On #tab-participation-processes" do
      Setting.create!(key: "process.whatever")

      visit admin_settings_path
      find("#participation-processes-tab").click
      within("tr", text: "Whatever") { click_button "No" }

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-participation-processes.is-active")
    end

    scenario "On #tab-feature-flags" do
      Setting.create!(key: "feature.whatever")

      visit admin_settings_path
      find("#features-tab").click
      within("tr", text: "Whatever") { click_button "No" }

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-feature-flags.is-active")
    end

    scenario "On #tab-sdg-configuration" do
      Setting["feature.sdg"] = true
      Setting.create!(key: "sdg.whatever")

      visit admin_settings_path
      click_link "SDG configuration"

      within("tr", text: "Whatever") do
        click_button "No"

        expect(page).to have_button "Yes"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("h2", exact_text: "SDG configuration")
    end
  end

  describe "Skip verification" do
    scenario "deactivate skip verification" do
      Setting["feature.user.skip_verification"] = "true"

      visit admin_settings_path
      find("#features-tab").click

      within("tr", text: "Skip user verification") do
        click_button "Yes"

        expect(page).to have_button "No"
      end
    end

    scenario "activate skip verification" do
      Setting["feature.user.skip_verification"] = nil

      visit admin_settings_path
      find("#features-tab").click

      within("tr", text: "Skip user verification") do
        click_button "No"

        expect(page).to have_button "Yes"
      end
    end
  end

  describe "SDG configuration tab" do
    scenario "is enabled when the sdg feature is enabled" do
      Setting["feature.sdg"] = true

      visit admin_settings_path
      click_link "SDG configuration"

      expect(page).to have_css "h2", exact_text: "SDG configuration"
    end

    scenario "is disabled when the sdg feature is disabled" do
      Setting["feature.sdg"] = false

      visit admin_settings_path
      click_link "SDG configuration"

      expect(page).to have_content "To show the configuration options from " \
                                   "Sustainable Development Goals you must " \
                                   'enable "SDG" on "Features" tab.'
    end

    scenario "is enabled right after enabling the feature" do
      Setting["feature.sdg"] = false

      visit admin_settings_path

      click_link "Features"

      within("tr", text: "SDG") do
        click_button "No"

        expect(page).to have_button "Yes"
      end

      click_link "SDG configuration"

      expect(page).to have_css "h2", exact_text: "SDG configuration"
    end
  end

  describe "Machine learning settings" do
    scenario "show the machine learning feature but not its settings" do
      Setting["feature.machine_learning"] = true

      visit admin_settings_path

      expect(page).not_to have_content "Machine Learning"
      expect(page).not_to have_content "Comments Summary"
      expect(page).not_to have_content "Related Content"
      expect(page).not_to have_content "Tags"
      expect(page).not_to have_css ".translation_missing"

      click_link "Features"

      expect(page).to have_content "Machine Learning"
      expect(page).not_to have_content "Comments Summary"
      expect(page).not_to have_content "Related Content"
      expect(page).not_to have_content "Tags"
      expect(page).not_to have_css ".translation_missing"
    end
  end
end
