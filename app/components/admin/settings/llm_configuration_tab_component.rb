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

  def sensemaker_disabled?
    !::Llm::Config.configured? || Tenant.current_secrets.sensemaker_data_folder.blank?
  end
end
