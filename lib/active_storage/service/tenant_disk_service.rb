require "active_storage/service/disk_service"

module ActiveStorage
  class Service::TenantDiskService < Service::DiskService
    def path_for(key)
      if Tenant.default?
        super
      else
        super.sub(root, File.join(root, Tenant.subfolder_path))
      end
    end
  end
end
