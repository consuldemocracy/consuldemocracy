class Admin::Settings::LlmConfigurationTabComponent < ApplicationComponent
  def tab
    "#tab-llm-configuration"
  end

  def providers
    Llm::Config.providers
  end

  def provider_options
    current = Setting["llm.provider"]
    options_values = providers.keys.map { |key| [key.to_s, key.to_s] }
    disabled_values = providers.reject { |_key, value| value[:enabled] }.keys

    options_for_select(options_values, selected: current, disabled: disabled_values)
  end

  def models
    provider = Setting["llm.provider"]
    return {} if provider.blank?

    RubyLLM.models.by_provider(provider.downcase.to_sym).to_h do |model|
      [model.name, { id: model.id }]
    end
  end

  def model_options
    current = Setting["llm.model"]
    options_values = models.map { |name, value| [name, value[:id]] }

    options_for_select(options_values, selected: current)
  end

  def model_disabled?
    Setting["llm.provider"].blank?
  end

  def feature_disabled?
    !::Llm::Config.configured?
  end

  def image_suggestions_disabled?
    !::Llm::Config.configured? || Tenant.current_secrets.pexels_access_key.blank?
  end

  def speech_to_text_provider_options
    current = Setting["llm.speech_to_text_provider"]
    available = speech_to_text_providers
    options_values = available.keys.map { |key| [key.to_s, key.to_s] }
    disabled_values = available.reject { |_key, value| value[:enabled] }.keys

    options_for_select(options_values, selected: current, disabled: disabled_values)
  end

  def speech_to_text_model_options
    provider = Setting["llm.speech_to_text_provider"]
    current = Setting["llm.speech_to_text_model"]

    options_for_select(Llm::Config.speech_to_text_models_for(provider), selected: current)
  end

  def speech_to_text_model_disabled?
    Setting["llm.speech_to_text_provider"].blank?
  end

  def speech_to_text_feature_disabled?
    !::Llm::Config.speech_to_text_model_available?
  end

  private

    def speech_to_text_providers
      providers.select do |key, _value|
        Llm::Config.speech_to_text_models_for(key).any?
      end
    end
end
