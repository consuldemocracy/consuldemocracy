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
    ::RemoteTranslations::Llm::Config.providers.transform_values do |props|
      { id: props[:id], enabled: props[:enabled] }
    end
  end

  def models
    provider = Setting["llm.provider"]
    return {} if provider.blank?

    RubyLLM.models.by_provider(provider.downcase.to_sym).each_with_object({}) do |model, hash|
      hash[model.name] = {
        id: model.id,
        enabled: true
      }
    end
  end
end
