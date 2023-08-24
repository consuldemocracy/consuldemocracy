require "rails_helper"

describe SiteCustomization::Image do
  describe "logo" do
    it "is valid with a 400x80 image" do
      image = build(:site_customization_image,
                    name: "logo_header",
                    image: fixture_file_upload("logo_email_custom.png"))

      expect(image).to be_valid
    end
  end
end
