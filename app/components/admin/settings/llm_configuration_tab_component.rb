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

    RubyLLM.models.by_provider(provider.downcase.to_sym).each_with_object({}) do |model, hash|
      hash[model.name] = {
        id: model.id
      }
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
    Setting["llm.provider"].blank? || Setting["llm.model"].blank?
  end

  def image_suggestions_disabled?
    Setting["llm.provider"].blank? ||
      Setting["llm.model"].blank? ||
      Tenant.current_secrets.pexels_access_key.blank?
  end
end
