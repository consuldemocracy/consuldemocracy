require "rails_helper"

describe Admin::Settings::LlmConfigurationTabComponent do
  let(:component) { Admin::Settings::LlmConfigurationTabComponent.new }
  let(:providers_config) do
    {
      OpenAI: { enabled: true },
      Anthropic: { enabled: false },
      Gemini: { enabled: true },
      Ollama: { enabled: true },
      VertexAI: { enabled: false }
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
  let(:sensemaker_provider_setting) { Setting.find_by!(key: "llm.sensemaker_provider") }
  let(:sensemaker_model_setting) { Setting.find_by!(key: "llm.sensemaker_model") }
  let(:provider_select_selector) { "#value_setting_#{provider_setting.id}" }
  let(:model_select_selector) { "#value_setting_#{model_setting.id}" }
  let(:feature_button_selector) { "button[aria-labelledby='title_setting_#{feature_setting.id}']" }
  let(:sensemaker_button_selector) { "button[aria-labelledby='title_setting_#{sensemaker_setting.id}']" }
  let(:sensemaker_provider_selector) { "#value_setting_#{sensemaker_provider_setting.id}" }
  let(:sensemaker_model_selector) { "#value_setting_#{sensemaker_model_setting.id}" }

  before do
    Setting["llm.provider"] = nil
    Setting["llm.model"] = nil
    Setting["llm.use_llm_for_translations"] = false
    Setting["llm.use_sensemaker"] = false
    Setting["llm.sensemaker_provider"] = nil
    Setting["llm.sensemaker_model"] = nil
    allow(Llm::Config).to receive(:providers).and_return(providers_config)
    allow(RubyLLM.models).to receive(:by_provider).with(:openai).and_return(models_for_openai)
  end

  context "when no content provider is configured" do
    it "renders content features disabled and shows both section headings" do
      render_inline component

      expect(page).to have_content "LLM Settings"
      expect(page).to have_content "Content features"
      expect(page).to have_content "Sensemaker features"

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
    end
  end

  context "when a content provider is configured but no model" do
    before { Setting["llm.provider"] = "OpenAI" }

    it "enables the model dropdown while keeping content feature toggles disabled" do
      render_inline component

      page.find(provider_select_selector) do
        expect(page).to have_selector(:option, "OpenAI", selected: true)
      end

      expect(page).to have_selector("#{model_select_selector} option", text: "GPT-4o")
      expect(page).to have_selector("#{model_select_selector} option", text: "GPT-4o-mini")
      expect(page).not_to have_xpath(
        "//select[@id='value_setting_#{model_setting.id}']/ancestor::fieldset[@disabled]"
      )

      page.find(feature_button_selector) do
        expect(page).to have_button "No", disabled: true
      end
    end
  end

  context "when both content provider and model are configured" do
    before do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
    end

    it "enables content feature toggles once provider and model are selected" do
      render_inline component

      page.find(provider_select_selector) do
        expect(page).to have_selector(:option, "OpenAI", selected: true)
      end

      expect(page).to have_selector("#{model_select_selector} option[selected]", text: "GPT-4o")
      expect(page).not_to have_xpath(
        "//select[@id='value_setting_#{model_setting.id}']/ancestor::fieldset[@disabled]"
      )

      page.find(feature_button_selector) do
        expect(page).to have_button "No", disabled: false
      end
    end
  end

  describe "sensemaker toggle" do
    before do
      Setting["llm.sensemaker_provider"] = "OpenAI"
      Setting["llm.sensemaker_model"] = "gpt-4o"
      Setting["llm.use_sensemaker"] = false
      allow(Llm::Config).to receive(:sensemaker_model_available?).and_return(true)
    end

    it "is disabled when sensemaker_data_folder is not configured" do
      stub_secrets(sensemaker_data_folder: "")

      render_inline component

      page.find(sensemaker_button_selector) do
        expect(page).to have_content "Sensemaker"
        expect(page).to have_button "No", disabled: true
      end
    end

    it "is enabled when Sensemaker LLM and sensemaker_data_folder are configured" do
      stub_secrets(sensemaker_data_folder: "vendor/sensemaking-tools/data")

      render_inline component

      page.find(sensemaker_button_selector) do
        expect(page).to have_button "No", disabled: false
      end
    end
  end

  context "when only some Sensemaker providers are configured" do
    let(:providers_config) do
      {
        OpenAI: { enabled: false },
        VertexAI: { enabled: true },
        Anthropic: { enabled: true }
      }
    end
    let(:models_for_vertex) do
      [
        double(name: "Gemini 2.5 Flash", id: "gemini-2.5-flash"),
        double(name: "Gemini 2.5 Pro", id: "gemini-2.5-pro")
      ]
    end

    before do
      Setting["llm.sensemaker_provider"] = "VertexAI"
      Setting["llm.sensemaker_model"] = "gemini-2.5-flash"
      allow(RubyLLM.models).to receive(:by_provider).with(:vertexai).and_return(models_for_vertex)
      allow(Llm::Config).to receive(:sensemaker_model_available?).and_return(true)
      stub_secrets(sensemaker_data_folder: "vendor/sensemaking-tools/data")
    end

    it "lists only supported providers and models for the selected Sensemaker provider" do
      render_inline component

      expect(page).to have_selector(
        "#{sensemaker_provider_selector} option[disabled]", text: "OpenAI"
      )
      expect(page).to have_selector(
        "#{sensemaker_provider_selector} option[selected]", text: "VertexAI"
      )
      expect(page).not_to have_selector(
        "#{sensemaker_provider_selector} option", text: "Anthropic"
      )

      expect(page).to have_selector(
        "#{sensemaker_model_selector} option[selected]", text: "Gemini 2.5 Flash"
      )
      expect(page).to have_selector(
        "#{sensemaker_model_selector} option", text: "Gemini 2.5 Pro"
      )

      page.find(sensemaker_button_selector) do
        expect(page).to have_button "No", disabled: false
      end
    end
  end
end
