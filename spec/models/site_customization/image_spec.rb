require "rails_helper"

describe SiteCustomization::Image do
  it "stores images with Active Storage" do
    image = create(:site_customization_image, name: "map",
                   image: fixture_file_upload("custom_map.jpg"))

    expect(image.image).to be_attached
    expect(image.image.filename).to eq "custom_map.jpg"
  end

  describe "logo" do
    it "is valid with a 260x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: fixture_file_upload("logo_header-260x80.png"))

      expect(image).to be_valid
    end

    it "is valid with a 223x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: fixture_file_upload("logo_header.png"))

      expect(image).to be_valid
    end

    it "is not valid with a 400x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: fixture_file_upload("logo_email_custom.png"))

      expect(image).not_to be_valid
    end

    it "dynamically validates the valid images" do
      stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "custom" => [223, 80] })

      custom = build(:site_customization_image, name: "custom", image: fixture_file_upload("logo_header.png"))
      expect(custom).to be_valid

      map = build(:site_customization_image, name: "map", image: fixture_file_upload("custom_map.jpg"))
      expect(map).not_to be_valid
    end
  end
end
