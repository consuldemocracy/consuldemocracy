require "rails_helper"

describe "Admin settings", :admin do
  scenario "Index" do
    visit admin_settings_path

    expect(page).to have_content "Level 1 public official"
    expect(page).to have_content "Maximum ratio of anonymous votes per Debate"
    expect(page).to have_content "Comments body max length"
  end

  scenario "Update" do
    visit admin_settings_path

    within "tr", text: "Level 1 public official" do
      fill_in "Level 1 public official", with: "Super Users of level 1"
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
        click_button "Update"
      end

      expect(page).to have_content "Map configuration updated successfully"
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
        click_button "Update"
      end

      expect(find("#latitude", visible: :hidden).value).not_to eq "51.48"
      expect(page).to have_content "Map configuration updated successfully"
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
        visit admin_settings_path
        find("#remote-census-tab").click

        within "tr", text: "Endpoint" do
          fill_in "Endpoint", with: "example.org/webservice"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-remote-census-configuration.is-active")
      end
    end

    scenario "On #tab-configuration" do
      visit admin_settings_path

      within "tr", text: "Level 1 public official" do
        fill_in "Level 1 public official", with: "Super Users of level 1"
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
        visit admin_settings_path
        click_link "Map configuration"

        within "tr", text: "Latitude" do
          fill_in "Latitude", with: "-3.636"
          click_button "Update"
        end

        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-map-configuration.is-active")
      end

      scenario "On #tab-map-configuration when using the interactive map" do
        visit admin_settings_path(anchor: "tab-map-configuration")
        within "#map-form" do
          click_button "Update"
        end

        expect(page).to have_content("Map configuration updated successfully.")
        expect(page).to have_current_path(admin_settings_path)
        expect(page).to have_css("div#tab-map-configuration.is-active")
      end
    end

    scenario "On #tab-proposals" do
      visit admin_settings_path
      find("#proposals-tab").click

      within "tr", text: "Polls description" do
        fill_in "Polls description", with: "Polls description"
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-proposals.is-active")
    end

    scenario "On #tab-participation-processes" do
      visit admin_settings_path
      find("#participation-processes-tab").click
      within("tr", text: "Debates") { click_button "Yes" }

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-participation-processes.is-active")
    end

    scenario "On #tab-feature-flags" do
      visit admin_settings_path
      find("#features-tab").click
      within("tr", text: "Featured proposals") { click_button "No" }

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("div#tab-feature-flags.is-active")
    end

    scenario "On #tab-sdg-configuration" do
      Setting["feature.sdg"] = true
      visit admin_settings_path
      click_link "SDG configuration"

      within("tr", text: "Related SDG in debates") do
        click_button "Yes"

        expect(page).to have_button "No"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_css("h2", exact_text: "SDG configuration")
    end

    scenario "On #tab-images-and-documents" do
      Setting["feature.sdg"] = true
      visit admin_settings_path(anchor: "tab-images-and-documents")
      within("tr", text: "Maximum number of documents") do
        fill_in "Maximum number of documents", with: 5
        click_button "Update"
      end

      expect(page).to have_current_path(admin_settings_path)
      expect(page).to have_field("Maximum number of documents", with: 5)
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

  describe "LLM settings" do
    context "Nothing is configured" do
      scenario "Provider and model are disabled, but Settings render without errors" do
        visit admin_settings_path
        click_link "LLM Settings"

        expect(page).to have_content "LLM Provider"
      end
    end

    context "Required LLM setup is configured" do
      scenario "Configure provider, model and enable usage" do
        # Ensure settings exist
        Setting["llm.provider"] = nil
        Setting["llm.model"] = nil
        Setting["llm.use_llm_for_translations"] = nil

        # Stub openai provider and models directly on the component
        allow_any_instance_of(Admin::Settings::LlmConfigurationTabComponent)
          .to receive(:providers)
          .and_return({ "OpenAI" => { id: "openai", enabled: true }})
        allow_any_instance_of(Admin::Settings::LlmConfigurationTabComponent)
          .to receive(:models)
          .and_return({ "gpt-4o-mini" => { id: "gpt-4o-mini", enabled: true }})
        model_double = double(name: "gpt-4o-mini", id: "gpt-4o-mini")
        allow(RubyLLM).to receive_message_chain(:models,
                                                :by_provider).with(:openai).and_return([model_double])

        visit admin_settings_path
        click_link "LLM Settings"

        # Select provider
        provider_setting = Setting.find_by!(key: "llm.provider")
        within "#edit_setting_#{provider_setting.id}" do
          select "OpenAI", from: "setting_value"
          click_button "Update"
        end

        # Provider selection triggers an ajax submit; wait until model row appears
        expect(page).to have_content "Model"

        # Select model
        model_setting = Setting.find_by!(key: "llm.model")
        within "#edit_setting_#{model_setting.id}" do
          select "gpt-4o-mini", from: "setting_value"
          click_button "Update"
        end

        # After provider and model are set, the feature toggle row should appear
        expect(page).to have_content "Use LLM for content translations"

        # Wait for the feature toggle to be enabled and click it
        within "tr", text: "Use LLM for content translations" do
          expect(page).to have_button "No"
          click_button "No"
        end

        # Wait for the AJAX request to complete
        expect(page).to have_content "Value updated"

        # Verify settings persisted
        expect(Setting.find_by!(key: "llm.provider").reload.value).to eq "OpenAI"
        expect(Setting.find_by!(key: "llm.model").reload.value).to eq "gpt-4o-mini"
        expect(Setting.find_by!(key: "llm.use_llm_for_translations").reload.value).to eq "active"
      end
    end
  end
end
