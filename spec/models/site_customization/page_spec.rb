require "rails_helper"

RSpec.describe SiteCustomization::Page, type: :model do
  let(:custom_page) { build(:site_customization_page) }

  it_behaves_like "globalizable", :site_customization_page

  it "is valid" do
    expect(custom_page).to be_valid
  end

  it "is invalid if slug has symbols" do
    custom_page = build(:site_customization_page, slug: "as/as*la")
    expect(custom_page).to be_invalid
  end

  it "dynamically validates the valid statuses" do
    stub_const("#{SiteCustomization::Page}::VALID_STATUSES", %w[custom])

    custom_page.status = "custom"
    expect(custom_page).to be_valid

    custom_page.status = "published"
    expect(custom_page).not_to be_valid
  end
end
