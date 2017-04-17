require 'rails_helper'

RSpec.describe SiteCustomization::Page, type: :model do
  let(:custom_page) { build(:site_customization_page) }

  it "should be valid" do
    expect(custom_page).to be_valid
  end

  it "is invalid if slug has symbols" do
    custom_page = build(:site_customization_page, slug: "as/as*la")
    expect(custom_page).to be_invalid
  end
end
