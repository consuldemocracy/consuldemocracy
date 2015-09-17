require 'rails_helper'

describe 'ActsAsTaggableOn::Tagging' do

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
