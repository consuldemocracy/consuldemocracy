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

      topic1 = create(:topic, community: community, author: user1)
      create(:comment, commentable: topic1, author: user1)
      create(:comment, commentable: topic1, author: user2)
      topic2 = create(:topic, community: community, author: user2)

      expect(community.participants).to include(user1)
      expect(community.participants).to include(user2)
      expect(community.participants).to include(proposal.author)
    end
  end
end
