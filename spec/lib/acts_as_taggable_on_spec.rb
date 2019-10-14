require 'rails_helper'

describe 'ActsAsTaggableOn' do

  describe 'Tagging' do
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

  describe 'Tag' do
    describe "#recalculate_custom_counter_for" do
      it "updates the counters of proposals and debates, taking into account hidden ones" do
        tag = ActsAsTaggableOn::Tag.create(name: "foo")

        create(:proposal, tag_list: "foo")
        create(:proposal, :hidden, tag_list: "foo")

        create(:debate, tag_list: "foo")
        create(:debate, :hidden, tag_list: "foo")

        tag.update(debates_count: 0, proposals_count: 0)

        tag.recalculate_custom_counter_for('Debate')
        expect(tag.debates_count).to eq(1)

        tag.recalculate_custom_counter_for('Proposal')
        expect(tag.proposals_count).to eq(1)
      end
    end
  end

end
