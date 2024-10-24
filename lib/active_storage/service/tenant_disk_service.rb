require "active_storage/service/disk_service"

module ActiveStorage
  class Service::TenantDiskService < Service::DiskService
    def tenant_root
      File.join(root, Tenant.subfolder_path)
    end

    def tenant_root_for(...)
      File.join(root, Tenant.subfolder_path_for(...))
    end

    def path_for(key)
      if Tenant.default?
        super
      else
        super.sub(root, tenant_root)
      end
    end
  end
end
