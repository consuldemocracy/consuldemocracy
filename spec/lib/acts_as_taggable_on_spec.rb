require "rails_helper"

describe ActsAsTaggableOn do

  describe "Tagging" do
    describe "when tagging debates or proposals" do
      let(:proposal) { create(:proposal) }
      let(:debate) { create(:debate) }

      it "increases and decreases the tag's custom counters" do
        tag = ActsAsTaggableOn::Tag.create(name: "foo")

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(0)

        proposal.tag_list.add("foo")
        proposal.save
        tag.reload

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(1)

        debate.tag_list.add("foo")
        debate.save
        tag.reload

        expect(tag.debates_count).to eq(1)
        expect(tag.proposals_count).to eq(1)

        proposal.tag_list.remove("foo")
        proposal.save
        tag.reload

        expect(tag.debates_count).to eq(1)
        expect(tag.proposals_count).to eq(0)

        debate.tag_list.remove("foo")
        debate.save
        tag.reload

        expect(tag.debates_count).to eq(0)
        expect(tag.proposals_count).to eq(0)
      end
    end
  end

  describe "Tag" do
    describe "#recalculate_custom_counter_for" do
      it "updates the counters of proposals and debates, taking into account hidden ones" do
        tag = ActsAsTaggableOn::Tag.create(name: "foo")

        create(:proposal, tag_list: "foo")
        create(:proposal, :hidden, tag_list: "foo")

        create(:debate, tag_list: "foo")
        create(:debate, :hidden, tag_list: "foo")

        tag.update(debates_count: 0, proposals_count: 0)

        tag.recalculate_custom_counter_for("Debate")
        expect(tag.debates_count).to eq(1)

        tag.recalculate_custom_counter_for("Proposal")
        expect(tag.proposals_count).to eq(1)
      end
    end

    describe "public_for_api scope" do

      it "returns tags whose kind is NULL and have at least one tagging whose taggable is not hidden" do
        tag = create(:tag, kind: nil)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save

        expect(ActsAsTaggableOn::Tag.public_for_api).to include(tag)
      end

      it "returns tags whose kind is 'category' and have at least one tagging whose taggable is not hidden" do
        tag = create(:tag, :category)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save

        expect(ActsAsTaggableOn::Tag.public_for_api).to include(tag)
      end

      it "blocks other kinds of tags" do
        tag = create(:tag, kind: "foo")
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save

        expect(ActsAsTaggableOn::Tag.public_for_api).not_to include(tag)
      end

      it "blocks tags that don't have at least one tagged element" do
        tag = create(:tag)

        expect(ActsAsTaggableOn::Tag.public_for_api).not_to include(tag)
      end

      it "only permits tags on proposals or debates" do
        tag_1 = create(:tag)
        tag_2 = create(:tag)
        tag_3 = create(:tag)

        proposal = create(:proposal)
        spending_proposal = create(:spending_proposal)
        debate = create(:debate)

        proposal.tag_list.add(tag_1)
        spending_proposal.tag_list.add(tag_2)
        debate.tag_list.add(tag_3)

        proposal.save
        spending_proposal.save
        debate.save

        expect(ActsAsTaggableOn::Tag.public_for_api).to match_array([tag_1, tag_3])
      end

      it "blocks tags after its taggings became hidden" do
        tag = create(:tag)
        proposal = create(:proposal)
        proposal.tag_list.add(tag)
        proposal.save

        expect(ActsAsTaggableOn::Tag.public_for_api).to include(tag)

        proposal.delete

        expect(ActsAsTaggableOn::Tag.public_for_api).to be_empty
      end
    end

    describe "search" do
      it "containing the word in the name" do
        create(:tag, name: "Familia")
        create(:tag, name: "Cultura")
        create(:tag, name: "Salud")
        create(:tag, name: "Famosos")

        expect(ActsAsTaggableOn::Tag.pg_search("f").length).to eq(2)
        expect(ActsAsTaggableOn::Tag.search("cultura").first.name).to eq("Cultura")
        expect(ActsAsTaggableOn::Tag.search("sal").first.name).to eq("Salud")
        expect(ActsAsTaggableOn::Tag.search("fami").first.name).to eq("Familia")
      end
    end

  end

end
