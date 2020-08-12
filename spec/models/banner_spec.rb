require "rails_helper"

describe Banner do
  let(:banner) { build(:banner) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :banner
    it_behaves_like "globalizable", :banner
  end

  it "is valid" do
    expect(banner).to be_valid
  end

  it "assigns default values to new banners" do
    banner = Banner.new

    expect(banner.background_color).to be_present
    expect(banner.font_color).to be_present
  end
end
