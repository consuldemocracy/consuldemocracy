require "rails_helper"

describe Tag do
  it "decreases tag_count when a debate is hidden" do
    debate = create(:debate)
    tag = create(:tag, taggables: [debate])

    expect(tag.taggings_count).to eq(1)

    debate.update!(hidden_at: Time.current)

    tag.reload
    expect(tag.taggings_count).to eq(0)
  end

  it "decreases tag_count when a proposal is hidden" do
    proposal = create(:proposal)
    tag = create(:tag, taggables: [proposal])

    expect(tag.taggings_count).to eq(1)

    proposal.update!(hidden_at: Time.current)

    tag.reload
    expect(tag.taggings_count).to eq(0)
  end

  describe "name validation" do
    it "160 char name should be valid" do
      tag = build(:tag, name: Faker::Lorem.characters(number: 160))
      expect(tag).to be_valid
    end
  end

  context "Same tag uppercase and lowercase" do
    before do
      create(:tag, name: "Health")
      create(:tag, name: "health")
    end

    it "assigns only one of the existing tags (we can't control which one)" do
      debate = create(:debate, tag_list: "Health")

      expect([["Health"], ["health"]]).to include debate.reload.tag_list
    end

    it "assigns existing tags instead of creating new similar ones" do
      debate = create(:debate, tag_list: "hEaLth")

      expect([["Health"], ["health"]]).to include debate.reload.tag_list
    end
  end
end
