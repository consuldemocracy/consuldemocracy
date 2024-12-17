require "rails_helper"

describe "rake db:mask_ips" do
  before { Rake::Task["db:mask_ips"].reenable }

  it "mask IPs on all tenants" do
    create(:visit, ip: "1.1.1.1")
    create(:visit, ip: "1.1.1.2")
    create(:visit, ip: "1.1.2.2")

    create(:tenant, schema: "myhometown")

    Tenant.switch("myhometown") do
      create(:visit, ip: "1.1.1.1")
      create(:visit, ip: "1.1.1.2")
      create(:visit, ip: "1.1.3.3")
    end

    Rake.application.invoke_task("db:mask_ips")

    expect(Visit.pluck(:ip)).to match_array %w[1.1.1.0 1.1.1.0 1.1.2.0]

    Tenant.switch("myhometown") do
      expect(Visit.pluck(:ip)).to match_array %w[1.1.1.0 1.1.1.0 1.1.3.0]
    end
  end
end
