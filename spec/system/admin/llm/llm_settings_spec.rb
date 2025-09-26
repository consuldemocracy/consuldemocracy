require "rails_helper"

describe "Admin LLM settings", :admin do
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
      allow(RubyLLM).to receive_message_chain(:models, :by_provider).with(:openai).and_return([model_double])

      visit admin_settings_path
      click_link "LLM Settings"

      # Select provider
      provider_setting = Setting.find_by!(key: "llm.provider")
      within "#edit_setting_#{provider_setting.id}" do
        select "OpenAI", from: "setting_value"
      end

      # Provider selection triggers an ajax submit; wait until model row appears
      expect(page).to have_content "Model"

      # Select model
      model_setting = Setting.find_by!(key: "llm.model")
      within "#edit_setting_#{model_setting.id}" do
        select "gpt-4o-mini", from: "setting_value"
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
      expect(Setting.find_by!(key: "llm.provider").reload.value).to eq "openai"
      expect(Setting.find_by!(key: "llm.model").reload.value).to eq "gpt-4o-mini"
      expect(Setting.find_by!(key: "llm.use_llm_for_translations").reload.value).to eq "active"
    end
  end
end
