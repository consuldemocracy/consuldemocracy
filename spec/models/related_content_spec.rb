require "rails_helper"

describe RelatedContent do

  let(:parent_relationable) { create([:proposal, :debate].sample) }
  let(:child_relationable) { create([:proposal, :debate].sample) }

  it "allows relationables from various classes" do
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
  end

  it "does not allow empty relationables" do
    expect(build(:related_content)).not_to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable)).not_to be_valid
    expect(build(:related_content, child_relationable: child_relationable)).not_to be_valid
  end

  it "does not allow repeated related contents" do
    related_content = create(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable, author: build(:user))
    new_related_content = build(:related_content, parent_relationable: related_content.parent_relationable, child_relationable: related_content.child_relationable)
    expect(new_related_content).not_to be_valid
  end

  describe "create_opposite_related_content" do
    let(:parent_relationable) { create(:proposal) }
    let(:child_relationable) { create(:debate) }
    let(:related_content) { build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable, author: build(:user)) }

    it "creates an opposite related_content" do
      expect { related_content.save }.to change { described_class.count }.by(2)
      expect(related_content.opposite_related_content.child_relationable_id).to eq(parent_relationable.id)
      expect(related_content.opposite_related_content.child_relationable_type).to eq(parent_relationable.class.name)
      expect(related_content.opposite_related_content.parent_relationable_id).to eq(child_relationable.id)
      expect(related_content.opposite_related_content.parent_relationable_type).to eq(child_relationable.class.name)
      expect(related_content.opposite_related_content.opposite_related_content.id).to eq(related_content.id)
    end
  end

  describe "#relationed_contents" do
    before do
      related_content = create(:related_content, parent_relationable: parent_relationable, child_relationable: create(:proposal), author: build(:user))
      create(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable, author: build(:user))

      2.times do
        related_content.send("score_positive", build(:user))
      end

      6.times do
        related_content.send("score_negative", build(:user))
      end
    end

    it "returns not hidden by reports related contents" do
      expect(parent_relationable.relationed_contents.count).to eq(1)
      expect(parent_relationable.relationed_contents.first.class.name).to eq(child_relationable.class.name)
      expect(parent_relationable.relationed_contents.first.id).to eq(child_relationable.id)
    end
  end

end
