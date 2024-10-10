require "rails_helper"

describe "Images" do
  before { Setting["uploads.images.min_height"] = 0 }

  describe "Metadata" do
    let(:image) { create(:image, attachment: fixture_file_upload("logo_header_with_metadata.jpg")) }

    scenario "download original images without metadata" do
      visit polymorphic_path(image.variant(nil))

      file = MiniMagick::Image.open(page.find("img")["src"])

      expect(file.exif).to be_empty
    end

    scenario "download transformed images without metadata" do
      visit polymorphic_path(image.variant(:large))

      file = MiniMagick::Image.open(page.find("img")["src"])

      expect(file.exif).to be_empty
    end
  end
end
