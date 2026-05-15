class SamlAuthSettings
  attr_reader :secrets

  def initialize(secrets)
    @secrets = secrets
  end

  def settings
    self.class.remote_settings(idp_metadata_url).dup.tap do |settings|
      settings[:sp_entity_id] = sp_entity_id if sp_entity_id.present?
      settings[:idp_sso_service_url] = idp_sso_service_url if idp_sso_service_url.present?
      settings[:allowed_clock_drift] = 1.minute

      settings.merge!(additional_settings)
    end
  end

  def self.remote_settings(idp_metadata_url)
    return {} if idp_metadata_url.blank?

    @remote_settings ||= {}
    @remote_settings[idp_metadata_url] ||= parsed_metadata(idp_metadata_url)
  end

  def self.parsed_metadata(idp_metadata_url)
    OneLogin::RubySaml::IdpMetadataParser.new.parse_remote_to_hash(idp_metadata_url)
  end

  private

    def idp_metadata_url
      secrets.saml_idp_metadata_url
    end

    def sp_entity_id
      secrets.saml_sp_entity_id
    end

    def idp_sso_service_url
      secrets.saml_idp_sso_service_url
    end

    def additional_settings
      secrets.saml_additional_settings.presence || {}
    end
end
