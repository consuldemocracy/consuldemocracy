module RemotelyTranslatable
  private

    def detect_remote_translations(*)
      return [] unless remote_translation_enabled?

      RemoteTranslation.for(*)
    end

    def remote_translation_enabled?
      Setting["feature.remote_translations"].present? &&
        RemoteTranslations::Caller.configured?
    end
end
