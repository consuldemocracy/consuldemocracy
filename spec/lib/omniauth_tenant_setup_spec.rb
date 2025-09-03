require "rails_helper"

describe OmniauthTenantSetup do
  describe "#saml" do
    it "uses different secrets for different tenants" do
      create(:tenant, schema: "mars")
      create(:tenant, schema: "venus")

      stub_secrets(
        saml_sp_entity_id: "https://default.consul.dev/saml/metadata",
        saml_idp_metadata_url: "https://default-idp.example.com/metadata",
        saml_idp_sso_service_url: "https://default-idp.example.com/sso",
        tenants: {
          mars: {
            saml_sp_entity_id: "https://mars.consul.dev/saml/metadata",
            saml_idp_metadata_url: "https://mars-idp.example.com/metadata",
            saml_idp_sso_service_url: "https://mars-idp.example.com/sso"
          },
          venus: {
            saml_sp_entity_id: "https://venus.consul.dev/saml/metadata",
            saml_idp_metadata_url: "https://venus-idp.example.com/metadata",
            saml_idp_sso_service_url: "https://venus-idp.example.com/sso"
          }
        }
      )

      Tenant.switch("mars") do
        mars_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "mars.consul.dev"
        }

        OmniauthTenantSetup.saml(mars_env)
        mars_strategy_options = mars_env["omniauth.strategy"].options

        expect(mars_strategy_options[:sp_entity_id]).to eq "https://mars.consul.dev/saml/metadata"
        expect(mars_strategy_options[:idp_metadata_url]).to eq "https://mars-idp.example.com/metadata"
        expect(mars_strategy_options[:idp_sso_service_url]).to eq "https://mars-idp.example.com/sso"
      end

      Tenant.switch("venus") do
        venus_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "venus.consul.dev"
        }

        OmniauthTenantSetup.saml(venus_env)
        venus_strategy_options = venus_env["omniauth.strategy"].options

        expect(venus_strategy_options[:sp_entity_id]).to eq "https://venus.consul.dev/saml/metadata"
        expect(venus_strategy_options[:idp_metadata_url]).to eq "https://venus-idp.example.com/metadata"
        expect(venus_strategy_options[:idp_sso_service_url]).to eq "https://venus-idp.example.com/sso"
      end
    end

    it "uses default secrets for non-overridden tenant" do
      create(:tenant, schema: "earth")

      stub_secrets(
        saml_sp_entity_id: "https://default.consul.dev/saml/metadata",
        saml_idp_metadata_url: "https://default-idp.example.com/metadata",
        saml_idp_sso_service_url: "https://default-idp.example.com/sso",
        tenants: {
          mars: {
            saml_sp_entity_id: "https://mars.consul.dev/saml/metadata",
            saml_idp_metadata_url: "https://mars-idp.example.com/metadata",
            saml_idp_sso_service_url: "https://mars-idp.example.com/sso"
          }
        }
      )

      Tenant.switch("earth") do
        earth_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "earth.consul.dev"
        }

        OmniauthTenantSetup.saml(earth_env)
        earth_strategy_options = earth_env["omniauth.strategy"].options

        expect(earth_strategy_options[:sp_entity_id]).to eq "https://default.consul.dev/saml/metadata"
        expect(earth_strategy_options[:idp_metadata_url]).to eq "https://default-idp.example.com/metadata"
        expect(earth_strategy_options[:idp_sso_service_url]).to eq "https://default-idp.example.com/sso"
      end
    end
  end

  describe "#oidc" do
    it "uses different secrets for different tenants" do
      create(:tenant, schema: "mars")
      create(:tenant, schema: "venus")

      stub_secrets(
        oidc_client_id: "default-client-id",
        oidc_client_secret: "default-client-secret",
        oidc_issuer: "https://default-oidc.example.com",
        oidc_redirect_uri: "https://default.consul.dev/auth/oidc/callback",
        tenants: {
          mars: {
            oidc_client_id: "mars-client-id",
            oidc_client_secret: "mars-client-secret",
            oidc_issuer: "https://mars-oidc.example.com",
            oidc_redirect_uri: "https://mars.consul.dev/auth/oidc/callback"
          },
          venus: {
            oidc_client_id: "venus-client-id",
            oidc_client_secret: "venus-client-secret",
            oidc_issuer: "https://venus-oidc.example.com",
            oidc_redirect_uri: "https://venus.consul.dev/auth/oidc/callback"
          }
        }
      )

      Tenant.switch("mars") do
        mars_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "mars.consul.dev"
        }

        OmniauthTenantSetup.oidc(mars_env)
        mars_strategy_options = mars_env["omniauth.strategy"].options

        expect(mars_strategy_options[:client_id]).to eq "mars-client-id"
        expect(mars_strategy_options[:client_secret]).to eq "mars-client-secret"
        expect(mars_strategy_options[:issuer]).to eq "https://mars-oidc.example.com"
        expect(mars_strategy_options[:redirect_uri]).to eq "https://mars.consul.dev/auth/oidc/callback"
      end

      Tenant.switch("venus") do
        venus_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "venus.consul.dev"
        }

        OmniauthTenantSetup.oidc(venus_env)
        venus_strategy_options = venus_env["omniauth.strategy"].options

        expect(venus_strategy_options[:client_id]).to eq "venus-client-id"
        expect(venus_strategy_options[:client_secret]).to eq "venus-client-secret"
        expect(venus_strategy_options[:issuer]).to eq "https://venus-oidc.example.com"
        expect(venus_strategy_options[:redirect_uri]).to eq "https://venus.consul.dev/auth/oidc/callback"
      end
    end

    it "uses default secrets for non-overridden tenant" do
      create(:tenant, schema: "earth")

      stub_secrets(
        oidc_client_id: "default-client-id",
        oidc_client_secret: "default-client-secret",
        oidc_issuer: "https://default-oidc.example.com",
        oidc_redirect_uri: "https://default.consul.dev/auth/oidc/callback",
        tenants: {
          mars: {
            oidc_client_id: "mars-client-id",
            oidc_client_secret: "mars-client-secret",
            oidc_issuer: "https://mars-oidc.example.com",
            oidc_redirect_uri: "https://mars.consul.dev/auth/oidc/callback"
          }
        }
      )

      Tenant.switch("earth") do
        earth_env = {
          "omniauth.strategy" => double(options: {}),
          "HTTP_HOST" => "earth.consul.dev"
        }

        OmniauthTenantSetup.oidc(earth_env)
        earth_strategy_options = earth_env["omniauth.strategy"].options

        expect(earth_strategy_options[:client_id]).to eq "default-client-id"
        expect(earth_strategy_options[:client_secret]).to eq "default-client-secret"
        expect(earth_strategy_options[:issuer]).to eq "https://default-oidc.example.com"
        expect(earth_strategy_options[:redirect_uri]).to eq "https://default.consul.dev/auth/oidc/callback"
      end
    end
  end
end
