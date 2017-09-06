require 'rails_helper'

feature 'Communities' do

  background do
    Setting['feature.community'] = true
  end

  after do
    Setting['feature.community'] = nil
  end

  context 'Show' do

    scenario 'Should display default content' do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      login_as(user)

      visit community_path(community)

      expect(page).to have_content "Proposal community"
      expect(page).to have_content proposal.title
      expect(page).to have_content "Participate in the community of this proposal"
      expect(page).to have_link("Create topic", href: new_community_topic_path(community))
      expect(page).not_to have_selector(".button.disabled", text: "Create topic")
    end

    scenario 'Should display disabled create topic button when user is not logged' do
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(page).to have_selector(".button.disabled", text: "Create topic")
    end

    scenario 'Should display without_topics_text and participants when there are not topics' do
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(page).to have_content "Create the first community topic"
      expect(page).to have_content "Participants (1)"
    end

    scenario 'Should display order selector and topic content when there are topics' do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)
      create(:comment, commentable: topic)

      visit community_path(community)

      expect(page).to have_selector ".wide-order-selector"
      within "#topic_#{topic.id}" do
        expect(page).to have_content topic.title
        expect(page).to have_content "#{topic.comments_count} comment"
        expect(page).to have_content I18n.l(topic.created_at.to_date)
        expect(page).to have_content topic.author.name
      end
    end

    scenario "Topic order" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)
      topic2_comment = create(:comment, :with_confidence_score, commentable: topic2)
      topic3 = create(:topic, community: community)
      topic3_comment = create(:comment, :with_confidence_score, commentable: topic3)
      topic3_comment = create(:comment, :with_confidence_score, commentable: topic3)

      visit community_path(community, order: :most_commented)

      expect(topic3.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic1.title)

      visit community_path(community, order: :oldest)

      expect(topic1.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic3.title)

      visit community_path(community, order: :newest)

      expect(topic3.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic1.title)
    end

    scenario "Should order by newest when order param is invalid" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)

      visit community_path(community, order: "invalid_param")

      expect(topic2.title).to appear_before(topic1.title)
    end

    scenario 'Should display topic edit button when author is logged' do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      topic1 = create(:topic, community: community, author: user)
      topic2 = create(:topic, community: community)
      login_as(user)

      visit community_path(community)

      within "#topic_#{topic1.id}" do
        expect(page).to have_link("Edit", href: edit_community_topic_path(community, topic1))
      end

      within "#topic_#{topic2.id}" do
        expect(page).not_to have_link("Edit", href: edit_community_topic_path(community, topic2))
      end
    end

    scenario 'Should display participant when there is topics' do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)

      visit community_path(community)

      within ".communities-participant" do
        expect(page).to have_content "Participants (2)"
        expect(page).to have_content topic.author.name
        expect(page).to have_content proposal.author.name
      end
    end

    scenario 'Should display participants when there are topics and comments' do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)
      comment = create(:comment, commentable: topic)

      visit community_path(community)

      within ".communities-participant" do
        expect(page).to have_content "Participants (3)"
        expect(page).to have_content topic.author.name
        expect(page).to have_content comment.author.name
        expect(page).to have_content proposal.author.name
      end
    end

    scenario 'Should redirect root path when communities are disabled' do
      Setting['feature.community'] = nil
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(current_path).to eq(root_path)
    end

  end

end
