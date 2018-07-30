require "rails_helper"

describe Tenant do
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
      expect(create(:tenant, schema: "subdomainx")).to be_valid
      expect(build(:tenant, schema: "subdomainx")).not_to be_valid
    end

    it "is not valid with an excluded subdomain" do
      %w[mail public www].each do |subdomain|
        tenant.schema = subdomain
        expect(tenant).not_to be_valid
      end
    end

    it "is not valid without a name" do
      tenant.name = ""
      expect(tenant).not_to be_valid
    end

    it "is not valid with an already existing name" do
      expect(create(:tenant, name: "Name X")).to be_valid
      expect(build(:tenant, name: "Name X")).not_to be_valid
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
