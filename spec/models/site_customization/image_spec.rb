require "rails_helper"

describe SiteCustomization::Image do
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

    it "is not valid with a 400x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: File.new("spec/fixtures/files/logo_email_custom.png"))

      expect(image).not_to be_valid
    end
  end
end
