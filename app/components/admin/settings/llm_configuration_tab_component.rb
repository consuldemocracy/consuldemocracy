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

    provider_sym = provider_name.downcase.to_sym
    secrets = Tenant.current_secrets.llm || {}
    url = secrets["ollama_api_base"] || "http://localhost:11434/v1"
    config = RubyLLM.context { |c| c.ollama_api_base = url }.config

    begin
      if provider_sym == :ollama
        provider = RubyLLM::Providers::Ollama.new(config)
        provider.list_models.each_with_object({}) do |model, hash|
          # Use ID as both key and value for reliability
          hash[model.id] = { id: model.id }
        end
      else
        RubyLLM.models.by_provider(provider_sym).all.each_with_object({}) do |model, hash|
          label = model.name.presence || model.id
          hash[label] = { id: model.id }
        end
      end
    rescue => e
      Rails.logger.error "[LlmTab] Failed to fetch #{provider_name} models: #{e.message}"
      {}
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
end
