require "rails_helper"

describe Tenant do
  describe ".resolve_host" do
    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "consul.dev" })
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

    context "multitenancy disabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

      it "always returns nil" do
        expect(Tenant.resolve_host("saturn.consul.dev")).to be nil
        expect(Tenant.resolve_host("jupiter.lvh.me")).to be nil
      end
    end

    context "default host contains subdomains" do
      before do
        allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "demo.consul.dev" })
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
        allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "mylvh.me" })
      end

      it "returns nil for the default host" do
        expect(Tenant.resolve_host("mylvh.me")).to be nil
      end

      it "returns subdomains when present" do
        expect(Tenant.resolve_host("neptune.mylvh.me")).to eq "neptune"
      end
    end
  end

  describe "validations" do
    let(:tenant) { build(:tenant) }

    it "is valid" do
      expect(tenant).to be_valid
    end

    it "is not valid without a subdomain" do
      tenant.subdomain = nil
      expect(tenant).not_to be_valid
    end

    it "is not valid with an already existing subdomain" do
      expect(create(:tenant, subdomain: "subdomainx")).to be_valid
      expect(build(:tenant, subdomain: "subdomainx")).not_to be_valid
    end

    it "is not valid with an excluded subdomain" do
      %w[mail public shared_extensions www].each do |subdomain|
        tenant.subdomain = subdomain
        expect(tenant).not_to be_valid
      end
    end

    it "is not valid with nested subdomains" do
      tenant.subdomain = "multiple.sub.domains"
      expect(tenant).not_to be_valid
    end

    it "is not valid with an invalid subdomain" do
      tenant.subdomain = "my sub domain"
      expect(tenant).not_to be_valid
    end

    it "is not valid without a name" do
      tenant.name = ""
      expect(tenant).not_to be_valid
    end
  end

  describe "#create_schema" do
    it "creates a schema creating a record" do
      create(:tenant, subdomain: "new")
      expect { Tenant.switch("new") { nil } }.not_to raise_exception
    end
  end

  describe "#rename_schema" do
    it "renames the schema when updating the subdomain" do
      tenant = create(:tenant, subdomain: "typo")
      tenant.update!(subdomain: "notypo")

      expect { Tenant.switch("typo") { nil } }.to raise_exception(Apartment::TenantNotFound)
      expect { Tenant.switch("notypo") { nil } }.not_to raise_exception
    end
  end

  describe "#destroy_schema" do
    it "drops the schema when destroying a record" do
      tenant = create(:tenant, subdomain: "wrong")
      tenant.destroy!

      expect { Tenant.switch("wrong") { nil } }.to raise_exception(Apartment::TenantNotFound)
    end
  end
end
