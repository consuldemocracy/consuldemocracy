require "rails_helper"

describe Topic do
  let(:topic) { build(:topic) }

  describe "Concerns" do
    it_behaves_like "notifiable"
  end

  it "is valid" do
    expect(topic).to be_valid
  end

  it "is not valid without an author" do
    topic.author = nil
    expect(topic).not_to be_valid
  end

  it "is not valid without a title" do
    topic.title = nil
    expect(topic).not_to be_valid
  end

  it "is not valid without a description" do
    topic.description = nil
    expect(topic).not_to be_valid
  end

  context "order" do

    it "orders by newest" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)
      topic3 = create(:topic, community: community)

      results = community.topics.sort_by_newest

      expect(results.first).to eq(topic3)
      expect(results.second).to eq(topic2)
      expect(results.third).to eq(topic1)
    end

    it "orders by oldest" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)
      topic3 = create(:topic, community: community)

      results = community.topics.sort_by_oldest

      expect(results.first).to eq(topic1)
      expect(results.second).to eq(topic2)
      expect(results.third).to eq(topic3)
    end

    it "orders by most_commented" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      create(:comment, commentable: topic1)
      create(:comment, commentable: topic1)
      topic2 = create(:topic, community: community)
      create(:comment, commentable: topic2)
      topic3 = create(:topic, community: community)

      results = community.topics.sort_by_most_commented

      expect(results.first).to eq(topic1)
      expect(results.second).to eq(topic2)
      expect(results.third).to eq(topic3)
    end

  end

  describe "notifications" do
    it_behaves_like "notifiable"
  end
end
