require "rails_helper"

describe SiteCustomization::Image do
  it "stores images with both Paperclip and Active Storage" do
    image = create(:site_customization_image, name: "map",
                   image: File.new("spec/fixtures/files/custom_map.jpg"))

    expect(image.image).to exist
    expect(image.image_file_name).to eq "custom_map.jpg"

    expect(image.storage_image).to be_attached
    expect(image.storage_image.filename).to eq "custom_map.jpg"
  end

  describe "logo" do
    it "is valid with a 260x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: File.new("spec/fixtures/files/logo_header-260x80.png"))

      expect(image).to be_valid
    end

    it "is valid with a 223x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: File.new("spec/fixtures/files/logo_header.png"))

      expect(image).to be_valid
    end

    it "is valid with a 400x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: File.new("spec/fixtures/files/logo_email_custom.png"))

      expect(image).to be_valid
    end
  end
end
