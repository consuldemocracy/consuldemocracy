require "rails_helper"

RSpec.describe SiteCustomization::ContentBlock do
  let(:block) { build(:site_customization_content_block) }

  it "is valid" do
    expect(block).to be_valid
  end

  it "name is unique per locale" do
    create(:site_customization_content_block, name: "top_links", locale: "en")
    invalid_block = build(:site_customization_content_block, name: "top_links", locale: "en")

    expect(invalid_block).not_to be_valid
    expect(invalid_block.errors.full_messages).to include("Name has already been taken")

    valid_block = build(:site_customization_content_block, name: "top_links", locale: "es")
    expect(valid_block).to be_valid
  end

  it "dynamically validates the valid blocks" do
    stub_const("#{SiteCustomization::ContentBlock}::VALID_BLOCKS", %w[custom])

    block.name = "custom"
    expect(block).to be_valid

    block.name = "top_links"
    expect(block).not_to be_valid
  end

  it "is not valid with a disabled locale" do
    Setting["locales.default"] = "nl"
    Setting["locales.enabled"] = "nl pt-BR"

    block.locale = "en"

    expect(block).not_to be_valid
  end
end
