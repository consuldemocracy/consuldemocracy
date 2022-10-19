require "rails_helper"

describe Attachable do
  it "stores tenant attachments in a folder for the tenant" do
    create(:tenant, subdomain: "image-master")

    Tenant.switch("image-master") do
      Setting.reset_defaults
      tenant_image = create(:image, attachment: fixture_file_upload("clippy.jpg"))

      expect(tenant_image.file_path).to include "storage/tenants/image-master/"
    end

    image = create(:image, attachment: fixture_file_upload("clippy.jpg"))

    expect(image.file_path).to include "storage/"
    expect(image.file_path).not_to include "storage//"
    expect(image.file_path).not_to include "image-master"
  end
end
