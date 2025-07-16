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
end
