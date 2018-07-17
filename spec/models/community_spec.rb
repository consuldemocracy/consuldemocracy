require 'rails_helper'

RSpec.describe Community, type: :model do

  it "is valid when create proposal" do
    proposal = create(:proposal)

    expect(proposal.community).to be_valid
  end

  describe "#participants" do

    it "returns participants without duplicates" do
      proposal = create(:proposal)
      community = proposal.community
      user1 = create(:user)
      user2 = create(:user)

      topic1 = create(:topic, community: community, author: user1)
      create(:comment, commentable: topic1, author: user1)
      create(:comment, commentable: topic1, author: user2)
      topic2 = create(:topic, community: community, author: user2)

      expect(community.participants).to include(user1)
      expect(community.participants).to include(user2)
      expect(community.participants).to include(proposal.author)
    end
  end

  # TODO: remove the trivial ones after migrating to a polymorphic association.
  describe "#communitable" do
    context "from proposal" do
      let(:proposal) { create(:proposal) }
      let(:community) { proposal.community }

      it "returns the proposal as communitable" do
        expect(community.communitable).to be(proposal)
      end

      it "returns proposal as communitable type" do
        expect(community.communitable_type).to eq "Proposal"
      end

      it "returns proposal as communitable key" do
        expect(community.communitable_key).to eq "proposal"
      end
    end

    context "from investment" do
      let(:investment) { create(:budget_investment) }
      let(:community) { investment.community }

      it "returns the investment as communitable" do
        expect(community.communitable).to be(investment)
      end

      it "returns budget investment as communitable type" do
        expect(community.communitable_type).to eq "Budget::Investment"
      end

      it "returns investment as communitable key" do
        expect(community.communitable_key).to eq "investment"
      end
    end
  end
end
