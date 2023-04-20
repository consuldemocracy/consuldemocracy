require "rails_helper"

describe AuthenticationLogger do
  describe ".path" do
    context "when multitenancy is disabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

      it "uses default file" do
        expect(AuthenticationLogger.path).to eq(Rails.root.join("log", "authentication.log"))
      end
    end

    context "when multitenancy is enabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(true) }

      it "uses the default file for the public schema" do
        Tenant.switch("public") do
          path = Rails.root.join("log", "authentication.log")

          expect(AuthenticationLogger.path).to eq(path)
        end
      end

      it "uses a separate file for any other tenant" do
        create(:tenant, schema: "tenant1")
        Tenant.switch("tenant1") do
          path = Rails.root.join("log", "tenants", "tenant1", "authentication.log")

          expect(AuthenticationLogger.path).to eq(path)
        end

        create(:tenant, schema: "tenant2")
        Tenant.switch("tenant2") do
          path = Rails.root.join("log", "tenants", "tenant2", "authentication.log")

          expect(AuthenticationLogger.path).to eq(path)
        end
      end
    end
  end
end
