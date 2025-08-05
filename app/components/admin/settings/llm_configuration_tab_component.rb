class Admin::Settings::LlmConfigurationTabComponent < ApplicationComponent
  def tab
    "#tab-llm-configuration"
  end

  def provider_setting
    Setting.find_by!(key: "llm.provider")
  end

  def model_setting
    Setting.find_by!(key: "llm.model")
  end

  def providers
    RubyLLM::Providers.constants.each_with_object({}) do |provider, hash|
      hash[provider] = {
        enabled: RubyLLM::Providers.const_get(provider).configured?
      }
    end
  end

  def models
    provider = Setting["llm.provider"]
    return {} if provider.blank?

    RubyLLM.models.by_provider(provider.downcase.to_sym).each_with_object({}) do |model, hash|
      hash[model.name] = {
        enabled: true
      }
    end
  end
end
