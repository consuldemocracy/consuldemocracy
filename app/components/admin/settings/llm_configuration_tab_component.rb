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
    provider_name = Setting["llm.provider"]
    return {} if provider_name.blank?

    Llm::Config.context

    provider_sym = provider_name.downcase.to_sym

    RubyLLM.models.by_provider(provider_sym).each_with_object({}) do |model, hash|
      label = model.name.presence || model.id
      hash[label] = { id: model.id }
    end
  rescue => e
    Rails.logger.error "[LlmTab] Failed to fetch #{provider_name} models: #{e.message}"
    {}
  end

  def model_options
    current = Setting["llm.model"]
    # Sort models alphabetically by name for a better UI experience
    options_values = models.map { |name, value| [name, value[:id]] }.sort

    options_for_select(options_values, selected: current)
  end

  def model_disabled?
    Setting["llm.provider"].blank?
  end

  def feature_disabled?
    Setting["llm.provider"].blank? || Setting["llm.model"].blank?
  end

  def image_suggestions_disabled?
    Setting["llm.provider"].blank? ||
      Setting["llm.model"].blank? ||
      Tenant.current_secrets.pexels_access_key.blank?
  end
end
