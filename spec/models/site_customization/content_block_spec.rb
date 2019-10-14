require 'rails_helper'

RSpec.describe SiteCustomization::ContentBlock, type: :model do
  let(:block) { build(:site_customization_content_block) }

  it "should be valid" do
    expect(block).to be_valid
  end

  it "name is unique per locale" do
    create(:site_customization_content_block, name: "top_links", locale: "en")
    invalid_block = build(:site_customization_content_block, name: "top_links", locale: "en")

    expect(invalid_block).to be_invalid
    expect(invalid_block.errors.full_messages).to include("Name has already been taken")

    valid_block = build(:site_customization_content_block, name: "top_links", locale: "es")
    expect(valid_block).to be_valid
  end
end
