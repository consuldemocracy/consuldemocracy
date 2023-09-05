require "rails_helper"

describe "Commenting topics from proposals" do
  let(:user)     { create :user }
  let(:proposal) { create :proposal }

  scenario "Show order links only if there are comments" do
    community = proposal.community
    topic = create(:topic, community: community)

    visit community_topic_path(community, topic)

    within "#tab-comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: topic, user: user)
    visit community_topic_path(community, topic)

    within "#tab-comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
