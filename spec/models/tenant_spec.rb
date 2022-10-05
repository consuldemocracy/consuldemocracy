require "rails_helper"

describe Tenant do
  describe ".resolve_host" do
    before do
      allow(Tenant).to receive(:default_url_options).and_return({ host: "consul.dev" })
    end

    it "returns nil for empty hosts" do
      expect(Tenant.resolve_host("")).to be nil
      expect(Tenant.resolve_host(nil)).to be nil
    end

    it "returns nil for IP addresses" do
      expect(Tenant.resolve_host("127.0.0.1")).to be nil
    end

    it "returns nil using development and test domains" do
      expect(Tenant.resolve_host("localhost")).to be nil
      expect(Tenant.resolve_host("lvh.me")).to be nil
      expect(Tenant.resolve_host("example.com")).to be nil
      expect(Tenant.resolve_host("www.example.com")).to be nil
    end

    it "treats lvh.me as localhost" do
      expect(Tenant.resolve_host("jupiter.lvh.me")).to eq "jupiter"
      expect(Tenant.resolve_host("www.lvh.me")).to be nil
    end

    it "returns nil for the default host" do
      expect(Tenant.resolve_host("consul.dev")).to be nil
    end

    it "ignores the www prefix" do
      expect(Tenant.resolve_host("www.consul.dev")).to be nil
    end

    it "returns subdomains when present" do
      expect(Tenant.resolve_host("saturn.consul.dev")).to eq "saturn"
    end

    it "ignores the www prefix when subdomains are present" do
      expect(Tenant.resolve_host("www.saturn.consul.dev")).to eq "saturn"
    end

    it "returns nested additional subdomains" do
      expect(Tenant.resolve_host("europa.jupiter.consul.dev")).to eq "europa.jupiter"
    end

    it "ignores the www prefix in additional nested subdomains" do
      expect(Tenant.resolve_host("www.europa.jupiter.consul.dev")).to eq "europa.jupiter"
    end

    it "does not ignore www if it isn't the prefix" do
      expect(Tenant.resolve_host("wwwsaturn.consul.dev")).to eq "wwwsaturn"
      expect(Tenant.resolve_host("saturn.www.consul.dev")).to eq "saturn.www"
    end

    it "returns the host as a subdomain" do
      expect(Tenant.resolve_host("consul.dev.consul.dev")).to eq "consul.dev"
    end

    it "returns nested subdomains containing the host" do
      expect(Tenant.resolve_host("saturn.consul.dev.consul.dev")).to eq "saturn.consul.dev"
    end

    it "returns full domains when they don't contain the host" do
      expect(Tenant.resolve_host("unrelated.dev")).to eq "unrelated.dev"
      expect(Tenant.resolve_host("mercury.anotherconsul.dev")).to eq "mercury.anotherconsul.dev"
    end

    it "ignores the www prefix in full domains" do
      expect(Tenant.resolve_host("www.unrelated.dev")).to eq "unrelated.dev"
      expect(Tenant.resolve_host("www.mercury.anotherconsul.dev")).to eq "mercury.anotherconsul.dev"
    end

    it "returns full domains when there's a tenant with a domain including the host" do
      insert(:tenant, :domain, schema: "saturn.consul.dev")

      expect(Tenant.resolve_host("saturn.consul.dev")).to eq "saturn.consul.dev"
    end

    it "returns subdomains when there's a subdomain-type tenant with that domain" do
      insert(:tenant, schema: "saturn.consul.dev")

      expect(Tenant.resolve_host("saturn.consul.dev")).to eq "saturn"
    end

    it "returns nil when a domain is accessed as a subdomain" do
      insert(:tenant, :domain, schema: "saturn.dev")

      expect(Tenant.resolve_host("saturn.dev.consul.dev")).to be nil
    end

    it "returns nested subdomains when there's a subdomain-type tenant with nested subdomains" do
      insert(:tenant, schema: "saturn.dev")

      expect(Tenant.resolve_host("saturn.dev.consul.dev")).to eq "saturn.dev"
    end

    it "returns domains when there are two tenants resolving to the same domain" do
      insert(:tenant, schema: "saturn")
      insert(:tenant, :domain, schema: "saturn.consul.dev")

      expect(Tenant.resolve_host("saturn.consul.dev")).to eq "saturn.consul.dev"
    end

    it "returns domains when there's a tenant using the default host" do
      insert(:tenant, :domain, schema: "consul.dev")

      expect(Tenant.resolve_host("consul.dev")).to eq "consul.dev"
    end

    it "returns domains including www when the tenant contains it" do
      insert(:tenant, :domain, schema: "www.consul.dev")

      expect(Tenant.resolve_host("www.consul.dev")).to eq "www.consul.dev"
    end

    context "multitenancy disabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

      it "always returns nil" do
        expect(Tenant.resolve_host("saturn.consul.dev")).to be nil
        expect(Tenant.resolve_host("jupiter.lvh.me")).to be nil
      end
    end

    context "default host contains subdomains" do
      before do
        allow(Tenant).to receive(:default_url_options).and_return({ host: "demo.consul.dev" })
      end

      it "ignores subdomains already present in the default host" do
        expect(Tenant.resolve_host("demo.consul.dev")).to be nil
      end

      it "ignores the www prefix" do
        expect(Tenant.resolve_host("www.demo.consul.dev")).to be nil
      end

      it "returns additional subdomains" do
        expect(Tenant.resolve_host("saturn.demo.consul.dev")).to eq "saturn"
      end

      it "ignores the www prefix in additional subdomains" do
        expect(Tenant.resolve_host("www.saturn.demo.consul.dev")).to eq "saturn"
      end

      it "returns nested additional subdomains" do
        expect(Tenant.resolve_host("europa.jupiter.demo.consul.dev")).to eq "europa.jupiter"
      end

      it "ignores the www prefix in additional nested subdomains" do
        expect(Tenant.resolve_host("www.europa.jupiter.demo.consul.dev")).to eq "europa.jupiter"
      end

      it "does not ignore www if it isn't the prefix" do
        expect(Tenant.resolve_host("wwwsaturn.demo.consul.dev")).to eq "wwwsaturn"
        expect(Tenant.resolve_host("saturn.www.demo.consul.dev")).to eq "saturn.www"
      end
    end

    context "default host is similar to development and test domains" do
      before do
        allow(Tenant).to receive(:default_url_options).and_return({ host: "mylvh.me" })
      end

      it "returns nil for the default host" do
        expect(Tenant.resolve_host("mylvh.me")).to be nil
      end

      it "returns subdomains when present" do
        expect(Tenant.resolve_host("neptune.mylvh.me")).to eq "neptune"
      end
    end
  end

  describe ".host_for" do
    before do
      allow(Tenant).to receive(:default_url_options).and_return({ host: "consul.dev" })
    end

    it "returns the default host for the default schema" do
      expect(Tenant.host_for("public")).to eq "consul.dev"
    end

    it "returns the host with a subdomain on other schemas" do
      expect(Tenant.host_for("uranus")).to eq "uranus.consul.dev"
    end

    it "uses lvh.me for subdomains when the host is localhost" do
      allow(Tenant).to receive(:default_url_options).and_return({ host: "localhost" })

      expect(Tenant.host_for("uranus")).to eq "uranus.lvh.me"
    end

    it "ignores the default host when given a full domain" do
      insert(:tenant, :domain, schema: "whole.galaxy")

      expect(Tenant.host_for("whole.galaxy")).to eq "whole.galaxy"
    end

    it "uses the default host when given nested subdomains" do
      insert(:tenant, schema: "whole.galaxy")

      expect(Tenant.host_for("whole.galaxy")).to eq "whole.galaxy.consul.dev"
    end
  end

  describe ".current_secrets" do
    context "same secrets for all tenants" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
          star: "Sun",
          volume: "Medium"
        ))
      end

      it "returns the default secrets for the default tenant" do
        allow(Tenant).to receive(:current_schema).and_return("public")

        expect(Tenant.current_secrets.star).to eq "Sun"
        expect(Tenant.current_secrets.volume).to eq "Medium"
      end

      it "returns the default secrets for other tenants" do
        allow(Tenant).to receive(:current_schema).and_return("earth")

        expect(Tenant.current_secrets.star).to eq "Sun"
        expect(Tenant.current_secrets.volume).to eq "Medium"
      end
    end

    context "tenant overwriting secrets" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
          star: "Sun",
          volume: "Medium",
          tenants: { proxima: { star: "Alpha Centauri" }}
        ))
      end

      it "returns the default secrets for the default tenant" do
        allow(Tenant).to receive(:current_schema).and_return("public")

        expect(Tenant.current_secrets.star).to eq "Sun"
        expect(Tenant.current_secrets.volume).to eq "Medium"
      end

      it "returns the overwritten secrets for tenants overwriting them" do
        allow(Tenant).to receive(:current_schema).and_return("proxima")

        expect(Tenant.current_secrets.star).to eq "Alpha Centauri"
        expect(Tenant.current_secrets.volume).to eq "Medium"
      end

      it "returns the default secrets for other tenants" do
        allow(Tenant).to receive(:current_schema).and_return("earth")

        expect(Tenant.current_secrets.star).to eq "Sun"
        expect(Tenant.current_secrets.volume).to eq "Medium"
      end
    end
  end

  describe ".run_on_each" do
    it "runs the code on all tenants, including the default one" do
      create(:tenant, schema: "andromeda")
      create(:tenant, schema: "milky-way")

      Tenant.run_on_each do
        Setting["org_name"] = "oh-my-#{Tenant.current_schema}"
      end

      expect(Setting["org_name"]).to eq "oh-my-public"

      Tenant.switch("andromeda") do
        expect(Setting["org_name"]).to eq "oh-my-andromeda"
      end

      Tenant.switch("milky-way") do
        expect(Setting["org_name"]).to eq "oh-my-milky-way"
      end
    end
  end

  describe "scopes" do
    describe ".domain" do
      it "returns tenants with domain schema type" do
        insert(:tenant, schema_type: :domain, schema: "full.domain")

        expect(Tenant.domain.pluck(:schema)).to eq ["full.domain"]
      end

      it "does not return tenants with subdomain schema type" do
        insert(:tenant, schema_type: :subdomain, schema: "nested.subdomain")

        expect(Tenant.domain).to be_empty
      end
    end
  end

  describe "validations" do
    let(:tenant) { build(:tenant) }

    it "is valid" do
      expect(tenant).to be_valid
    end

    it "is not valid without a schema" do
      tenant.schema = nil
      expect(tenant).not_to be_valid
    end

    it "is not valid with an already existing schema" do
      insert(:tenant, schema: "subdomainx")
      expect(build(:tenant, schema: "subdomainx")).not_to be_valid
    end

    it "is not valid with an excluded subdomain" do
      %w[mail public shared_extensions www].each do |subdomain|
        tenant.schema = subdomain
        expect(tenant).not_to be_valid
      end
    end

    it "is valid with nested subdomains" do
      tenant.schema = "multiple.sub.domains"
      expect(tenant).to be_valid
    end

    it "is not valid with an invalid subdomain" do
      tenant.schema = "my sub domain"
      expect(tenant).not_to be_valid
    end

    it "is not valid without a name" do
      tenant.name = ""
      expect(tenant).not_to be_valid
    end

    it "is not valid with an already existing name" do
      insert(:tenant, name: "Name X")
      expect(build(:tenant, name: "Name X")).not_to be_valid
    end

    context "Domain schema type" do
      before { tenant.schema_type = :domain }

      it "is valid with domains" do
        tenant.schema = "my.domain"
        expect(tenant).to be_valid
      end

      it "is valid with domains which are machine names" do
        tenant.schema = "localmachine"
        expect(tenant).to be_valid
      end
    end
  end

  describe "#create_schema" do
    it "creates a schema creating a record" do
      create(:tenant, schema: "new")
      expect { Tenant.switch("new") { nil } }.not_to raise_exception
    end
  end

  describe "#rename_schema" do
    it "renames the schema when updating the schema" do
      tenant = create(:tenant, schema: "typo")
      tenant.update!(schema: "notypo")

      expect { Tenant.switch("typo") { nil } }.to raise_exception(Apartment::TenantNotFound)
      expect { Tenant.switch("notypo") { nil } }.not_to raise_exception
    end
  end

  describe "#destroy_schema" do
    it "drops the schema when destroying a record" do
      tenant = create(:tenant, schema: "wrong")
      tenant.destroy!

      expect { Tenant.switch("wrong") { nil } }.to raise_exception(Apartment::TenantNotFound)
    end
  end
end
