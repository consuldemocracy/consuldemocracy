require "rails_helper"

describe Attachable do
  it "stores attachments for the default tenant in the default folder" do
    file_path = build(:image).file_path

    expect(file_path).to include "storage/"
    expect(file_path).not_to include "storage//"
    expect(file_path).not_to include "tenants"
  end

  it "stores tenant attachments in a folder for the tenant" do
    allow(Tenant).to receive(:current_schema).and_return("image-master")

    expect(build(:image).file_path).to include "storage/tenants/image-master/"
  end
end
