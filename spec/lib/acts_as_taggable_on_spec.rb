require "rails_helper"

describe ActsAsTaggableOn do
  describe "Tagging" do
    describe "when tagging debates or proposals" do
      let(:proposal) { create(:proposal) }
      let(:debate) { create(:debate) }

      it "increases and decreases the tag's custom counters" do
        tag = Tag.create!(name: "foo")

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(0)

        proposal.tag_list.add("foo")
        proposal.save!
        tag.reload

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(1)

        debate.tag_list.add("foo")
        debate.save!
        tag.reload

        expect(tag.debates_count).to eq(1)
        expect(tag.proposals_count).to eq(1)

        proposal.tag_list.remove("foo")
        proposal.save!
        tag.reload

        expect(tag.debates_count).to eq(1)
        expect(tag.proposals_count).to eq(0)

        debate.tag_list.remove("foo")
        debate.save!
        tag.reload

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(0)
      end
    end
  end

  describe "Tag" do
    describe "public_for_api scope" do
      it "returns tags whose kind is NULL and have at least one tagging whose taggable is not hidden" do
        tag = create(:tag, kind: nil)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save!

        expect(Tag.public_for_api).to eq [tag]
      end

      it "returns tags whose kind is 'category' and have at least one tagging whose taggable is not hidden" do
        tag = create(:tag, :category)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save!

        expect(Tag.public_for_api).to eq [tag]
      end

      it "blocks other kinds of tags" do
        tag = create(:tag, kind: "foo")
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save!

        expect(Tag.public_for_api).to be_empty
      end

      it "blocks tags that don't have at least one tagged element" do
        create(:tag)

        expect(Tag.public_for_api).to be_empty
      end

      it "only permits tags on proposals or debates" do
        tag_1 = create(:tag)
        tag_2 = create(:tag)
        tag_3 = create(:tag)

        proposal = create(:proposal)
        budget_investment = create(:budget_investment)
        debate = create(:debate)

        proposal.tag_list.add(tag_1)
        budget_investment.tag_list.add(tag_2)
        debate.tag_list.add(tag_3)

        proposal.save!
        budget_investment.save!
        debate.save!

        expect(Tag.public_for_api).to match_array([tag_1, tag_3])
      end

      it "blocks tags after its taggings became hidden" do
        tag = create(:tag)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save!

        expect(Tag.public_for_api).to eq [tag]

        proposal.delete

        expect(Tag.public_for_api).to be_empty
      end
    end

    describe "search" do
      it "containing the word in the name" do
        create(:tag, name: "Familia")
        create(:tag, name: "Cultura")
        create(:tag, name: "Salud")
        create(:tag, name: "Famosos")

        expect(Tag.pg_search("f").length).to eq(2)
        expect(Tag.search("cultura").first.name).to eq("Cultura")
        expect(Tag.search("sal").first.name).to eq("Salud")
        expect(Tag.search("fami").first.name).to eq("Familia")
      end
    end
  end
end
