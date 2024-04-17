require "rails_helper"
require "active_storage/service/tenant_disk_service"

describe ActiveStorage::Service::TenantDiskService do
  describe "#tenant_root_for" do
    it "returns the folder of the given tenant" do
      service = ActiveStorage::Service::TenantDiskService.new(root: Rails.root.join("tmp", "storage"))

      expect(service.tenant_root_for("megawonder")).to eq "#{Rails.root}/tmp/storage/tenants/megawonder"
    end
  end
end
