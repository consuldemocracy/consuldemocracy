module RemotelyTranslatable
  private

    def detect_remote_translations(*)
      return [] if RemoteTranslations::Caller.translation_provider.blank?

      RemoteTranslation.for(*)
    end

    def remote_translation_enabled?
      Setting["feature.remote_translations"].present? &&
        RemoteTranslations::Caller.translation_provider.present?
    end
end
