require "rails_helper"

describe RestrictAdminIps do
  it "allows any IP when allowed_admin_ips isn't configured" do
    stub_secrets(security: {})

    expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
    expect(RestrictAdminIps.new("whatever")).to be_allowed
  end

  it "allows any IP when allowed_admin_ips is empty" do
    stub_secrets(security: { allowed_admin_ips: [] })

    expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
    expect(RestrictAdminIps.new("whatever")).to be_allowed
  end

  it "only allows IPs present in allowed_admin_ips" do
    stub_secrets(security: { allowed_admin_ips: ["1.2.3.4", "5.6.7.8"] })

    expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
    expect(RestrictAdminIps.new("5.6.7.8")).to be_allowed
    expect(RestrictAdminIps.new("9.9.9.9")).not_to be_allowed
    expect(RestrictAdminIps.new("whatever")).not_to be_allowed
  end

  it "restricts every IP when there are only malformed IPs on the list" do
    stub_secrets(security: { allowed_admin_ips: ["not_an_ip"] })

    expect(RestrictAdminIps.new("1.2.3.4")).not_to be_allowed
    expect(RestrictAdminIps.new("not_an_ip")).not_to be_allowed
  end

  it "ignores malformed IPs in the allowed_admin_ips list" do
    stub_secrets(security: { allowed_admin_ips: ["1.2.3.4", "not_an_ip"] })

    expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
    expect(RestrictAdminIps.new("not_an_ip")).not_to be_allowed
  end

  it "supports ranges of IPs" do
    stub_secrets(security: { allowed_admin_ips: ["1.2.3.0/16"] })

    expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
    expect(RestrictAdminIps.new("1.2.3.5")).to be_allowed
    expect(RestrictAdminIps.new("5.6.7.8")).not_to be_allowed
  end

  context "tenant overwriting secrets" do
    before do
      stub_secrets({
        security: {
          allowed_admin_ips: ["1.2.3.4", "5.6.7.8"]
        },
        tenants: {
          private: {
            security: {
              allowed_admin_ips: ["127.0.0.1", "192.168.1.1"]
            }
          }
        }
      })
    end

    it "uses the general secrets for the main tenant" do
      expect(RestrictAdminIps.new("1.2.3.4")).to be_allowed
      expect(RestrictAdminIps.new("5.6.7.8")).to be_allowed
      expect(RestrictAdminIps.new("127.0.0.1")).not_to be_allowed
      expect(RestrictAdminIps.new("192.168.1.1")).not_to be_allowed
    end

    it "uses the tenant secrets for a tenant" do
      allow(Tenant).to receive(:current_schema).and_return("private")

      expect(RestrictAdminIps.new("127.0.0.1")).to be_allowed
      expect(RestrictAdminIps.new("192.168.1.1")).to be_allowed
      expect(RestrictAdminIps.new("1.2.3.4")).not_to be_allowed
      expect(RestrictAdminIps.new("5.6.7.8")).not_to be_allowed
    end
  end
end
