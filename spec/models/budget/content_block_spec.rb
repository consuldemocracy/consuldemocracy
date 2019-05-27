require "rails_helper"

describe Budget::ContentBlock do
  let(:block) { build(:heading_content_block) }

  it "is valid" do
    expect(block).to be_valid
  end

  it "Heading is unique per locale" do
    heading_content_block_en = create(:heading_content_block, locale: "en")
    invalid_block = build(:heading_content_block,
                          heading: heading_content_block_en.heading, locale: "en")

    expect(invalid_block).to be_invalid
    expect(invalid_block.errors.full_messages).to include("Heading has already been taken")

    valid_block = build(:heading_content_block,
                        heading: heading_content_block_en.heading, locale: "es")
    expect(valid_block).to be_valid
  end
end
