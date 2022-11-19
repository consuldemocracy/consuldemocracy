require "rails_helper"

describe ApplicationMailer do
  describe "#default_url_options" do
    it "returns the same options on the default tenant" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "consul.dev" })

      expect(ApplicationMailer.new.default_url_options).to eq({ host: "consul.dev" })
    end

    it "returns the host with a subdomain on other tenants" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "consul.dev" })
      allow(Tenant).to receive(:current_schema).and_return("my")

      expect(ApplicationMailer.new.default_url_options).to eq({ host: "my.consul.dev" })
    end

    it "uses lvh.me for subdomains when the host is localhost" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: "localhost", port: 3000 })
      allow(Tenant).to receive(:current_schema).and_return("dev")

      expect(ApplicationMailer.new.default_url_options).to eq({ host: "dev.lvh.me", port: 3000 })
    end
  end

  describe "#set_asset_host" do
    let(:mailer) { ApplicationMailer.new }

    it "returns a host based on the default_url_options by default" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return(host: "consul.dev")

      mailer.set_asset_host

      expect(mailer.asset_host).to eq "http://consul.dev"
    end

    it "considers options like port and protocol" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return(
        host: "localhost",
        protocol: "https",
        port: 3000
      )

      mailer.set_asset_host

      expect(mailer.asset_host).to eq "https://localhost:3000"
    end

    it "returns the host with a subdomain on other tenants" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return(host: "consul.dev")
      allow(Tenant).to receive(:current_schema).and_return("my")

      mailer.set_asset_host

      expect(mailer.asset_host).to eq "http://my.consul.dev"
    end

    it "uses lvh.me for subdomains when the host is localhost" do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return(host: "localhost", port: 3000)
      allow(Tenant).to receive(:current_schema).and_return("dev")

      mailer.set_asset_host

      expect(mailer.asset_host).to eq "http://dev.lvh.me:3000"
    end

    it "returns the asset host when set manually" do
      default_asset_host = ActionMailer::Base.asset_host

      begin
        ActionMailer::Base.asset_host = "http://consulassets.dev"

        mailer.set_asset_host

        expect(mailer.asset_host).to eq "http://consulassets.dev"
      ensure
        ActionMailer::Base.asset_host = default_asset_host
      end
    end
  end
end
