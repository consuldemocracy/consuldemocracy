require "rails_helper"

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
      user3 = create(:user)

      topic1 = create(:topic, community: community, author: user1)
      create(:comment, commentable: topic1, author: user1)
      create(:comment, commentable: topic1, author: user2)
      create(:topic, community: community, author: user2)
      create(:comment, commentable: proposal, author: user3)

      expect(community.participants).to match_array [user1, user2, proposal.author]
    end
  end
end
