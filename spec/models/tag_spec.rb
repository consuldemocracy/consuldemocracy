require "rails_helper"

describe Tag do

  it "decreases tag_count when a debate is hidden" do
    debate = create(:debate)
    tag = create(:tag)
    tagging = create(:tagging, tag: tag, taggable: debate)

    expect(tag.taggings_count).to eq(1)

    debate.update(hidden_at: Time.now)

    tag.reload
    expect(tag.taggings_count).to eq(0)
  end

  it "decreases tag_count when a proposal is hidden" do
    proposal = create(:proposal)
    tag = create(:tag)
    tagging = create(:tagging, tag: tag, taggable: proposal)

    expect(tag.taggings_count).to eq(1)

    proposal.update(hidden_at: Time.now)

    tag.reload
    expect(tag.taggings_count).to eq(0)
  end

  describe "name validation" do
    it "160 char name should be valid" do
      tag = build(:tag, name: Faker::Lorem.characters(160))
      expect(tag).to be_valid
    end
  end
end
