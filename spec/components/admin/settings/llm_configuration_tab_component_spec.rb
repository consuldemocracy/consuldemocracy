require "rails_helper"

describe Admin::Settings::LlmConfigurationTabComponent do
  let(:component) { Admin::Settings::LlmConfigurationTabComponent.new }
  let(:providers_config) do
    {
      OpenAI: { enabled: true },
      Anthropic: { enabled: false },
      Gemini: { enabled: true }
    }
  end
  let(:models_for_openai) do
    [
      double(name: "GPT-4o", id: "gpt-4o", created_at: Time.current),
      double(name: "GPT-4o-mini", id: "gpt-4o-mini", created_at: Time.current),
      double(name: "GPT-3.5 Turbo", id: "gpt-3.5-turbo", created_at: 2.years.ago),
      double(name: "Undated", id: "undated-model", created_at: nil)
    ]
  end
  let(:provider_setting) { Setting.find_by!(key: "llm.provider") }
  let(:model_setting) { Setting.find_by!(key: "llm.model") }
  let(:feature_setting) { Setting.find_by!(key: "llm.use_llm_for_translations") }
  let(:provider_select_id) { "value_setting_#{provider_setting.id}" }
  let(:model_select_id) { "value_setting_#{model_setting.id}" }
  let(:feature_button_selector) { "button[aria-labelledby='title_setting_#{feature_setting.id}']" }

  before do
    Setting["llm.provider"] = nil
    Setting["llm.model"] = nil
    Setting["llm.use_llm_for_translations"] = false
    allow(Llm::Config).to receive(:providers).and_return(providers_config)
    allow(RubyLLM.models).to receive(:by_provider).with(:openai).and_return(models_for_openai)
  end

  context "when no provider is configured" do
    it "renders the default state with disabled model select and feature toggle" do
      render_inline component

      expect(page).to have_content "LLM Settings"

      page.find("tr", text: "LLM Provider") do |provider_row|
        expect(provider_row).to have_content "LLM Provider"
        expect(provider_row).to have_content "Providers will be disabled until credentials are configured " \
                                             "in the secrets.yml."
        expect(provider_row).to have_select provider_select_id,
                                            options: ["None", "OpenAI", "Anthropic", "Gemini"],
                                            disabled_options: ["Anthropic"],
                                            selected: nil
      end

      page.find("tr", text: "Model") do |model_row|
        expect(model_row).to have_content "The LLM model to use."
        expect(model_row).to have_css "fieldset[disabled]"
        expect(model_row).to have_select model_select_id, options: ["None"], selected: nil
      end

      page.find("tr", text: "Content Translation") do |translation_row|
        expect(translation_row).to have_content "Use LLM for content translations and take precedence over " \
                                                "Microsoft translation services."
        expect(translation_row).to have_css feature_button_selector
        expect(translation_row).to have_button "No", disabled: true
      end
    end
  end

  context "when a provider is configured but no model" do
    before { Setting["llm.provider"] = "OpenAI" }

    it "enables the model dropdown while keeping the feature toggle disabled" do
      render_inline component

      page.find("tr", text: "LLM Provider") do |provider_row|
        expect(provider_row).to have_select selected: "OpenAI"
      end

      page.find("tr", text: "Model") do |model_row|
        expect(model_row).to have_select model_select_id,
                                         options: ["None", "GPT-4o", "GPT-4o-mini"],
                                         selected: nil
        expect(model_row).not_to have_css "fieldset[disabled]"
      end

      page.find("tr", text: "Content Translation") do |translation_row|
        expect(translation_row).to have_css feature_button_selector
        expect(translation_row).to have_button "No", disabled: true
      end
    end
  end

  context "when both provider and model are configured" do
    before do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
    end

    it "enables the feature toggle once provider and model are selected" do
      render_inline component

      page.find("tr", text: "LLM Provider") do |provider_row|
        expect(provider_row).to have_select selected: "OpenAI"
      end

      page.find("tr", text: "Model") do |model_row|
        expect(model_row).to have_select options: ["None", "GPT-4o", "GPT-4o-mini"],
                                         selected: "GPT-4o"
        expect(model_row).not_to have_css "fieldset[disabled]"
      end

      page.find("tr", text: "Content Translation") do |translation_row|
        expect(translation_row).to have_css feature_button_selector
        expect(translation_row).to have_button "No", disabled: false
      end
    end
  end
end
