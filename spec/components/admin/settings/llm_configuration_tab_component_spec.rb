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
      double(name: "GPT-4o", id: "gpt-4o"),
      double(name: "GPT-4o-mini", id: "gpt-4o-mini")
    ]
  end
  let(:provider_setting) { Setting.find_by!(key: "llm.provider") }
  let(:model_setting) { Setting.find_by!(key: "llm.model") }
  let(:feature_setting) { Setting.find_by!(key: "llm.use_llm_for_translations") }
  let(:sensemaker_setting) { Setting.find_by!(key: "llm.use_sensemaker") }
  let(:provider_select_selector) { "#value_setting_#{provider_setting.id}" }
  let(:model_select_selector) { "#value_setting_#{model_setting.id}" }
  let(:feature_button_selector) { "button[aria-labelledby='title_setting_#{feature_setting.id}']" }
  let(:sensemaker_button_selector) { "button[aria-labelledby='title_setting_#{sensemaker_setting.id}']" }

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

      page.find(provider_select_selector) do
        expect(page).to have_content "LLM Provider"
        expect(page).to have_content "Providers will be disabled until credentials are configured " \
                                     "in the secrets.yml."
        expect(page).to have_selector(:option, "OpenAI", selected: false)
        expect(page).to have_selector(:option, "Gemini", selected: false)
        expect(page).to have_selector(:option, "Anthropic", disabled: true, selected: false)
      end

      page.find(model_select_selector) do
        expect(page).to have_content "Model"
        expect(page).to have_content "The LLM model to use."
        expect(page).to have_css "fieldset[disabled]"
      end

      page.find(feature_button_selector) do
        expect(page).to have_content "Content Translation"
        expect(page).to have_content "Use LLM for content translations and take precedence over " \
                                     "Microsoft translation services."
        expect(page).to have_button "No", disabled: true
      end

      stub_secrets(sensemaker_data_folder: "vendor/sensemaking-tools/data")

      page.find(sensemaker_button_selector) do
        expect(page).to have_button "No", disabled: true
      end
    end
  end

  context "when a provider is configured but no model" do
    before { Setting["llm.provider"] = "OpenAI" }

    it "enables the model dropdown while keeping the feature toggle disabled" do
      render_inline component

      page.find(provider_select_selector) do
        expect(page).to have_selector(:option, "OpenAI", selected: true)
      end

      page.find(model_select_selector) do
        expect(page).to have_selector(:option, "GPT-4o", selected: false)
        expect(page).to have_selector(:option, "GPT-4o-mini", selected: false)
        expect(page).not_to have_css "fieldset[disabled]"
      end

      page.find(feature_button_selector) do
        expect(page).to have_button "No", disabled: true
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

      page.find(provider_select_selector) do
        expect(page).to have_selector(:option, "OpenAI", selected: true)
      end

      page.find(model_select_selector) do
        expect(page).to have_selector(:option, "GPT-4o", selected: true)
        expect(page).not_to have_css "fieldset[disabled]"
      end

      page.find(feature_button_selector) do
        expect(page).to have_button "No", disabled: false
      end
    end
  end

  describe "sensemaker toggle" do
    before do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_sensemaker"] = false
    end

    it "is disabled when sensemaker_data_folder is not configured" do
      stub_secrets(sensemaker_data_folder: "")

      render_inline component

      page.find(sensemaker_button_selector) do
        expect(page).to have_content "Sensemaker"
        expect(page).to have_button "No", disabled: true
      end
    end

    it "is enabled when LLM and sensemaker_data_folder are configured" do
      stub_secrets(sensemaker_data_folder: "vendor/sensemaking-tools/data")

      render_inline component

      page.find(sensemaker_button_selector) do
        expect(page).to have_button "No", disabled: false
      end
    end
  end
end
