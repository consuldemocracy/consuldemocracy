module RemotelyTranslatable
  private

    def detect_remote_translations(*args)
      return [] unless Setting["feature.remote_translations"].present? && api_key_has_been_set_in_secrets?

      RemoteTranslation.for(*args)
    end

    def api_key_has_been_set_in_secrets?
      Tenant.current_secrets.microsoft_api_key.present?
    end
end
