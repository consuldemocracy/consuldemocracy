require "rails_helper"

describe "Topics" do
  context "Concerns" do
    it_behaves_like "notifiable in-app", :topic_with_community
  end

  context "New" do
    scenario "Create new topic link should redirect to sign up for anonymous users" do
      proposal = create(:proposal)
      community = proposal.community

      logout
      visit community_path(community)
      click_link "Create topic"

      expect(page).to have_content "Sign in with:"
      expect(page).to have_current_path(new_user_session_path)
    end

    scenario "Can access to new topic page with user logged" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      login_as(user)
      visit community_path(community)

      click_link "Create topic"

      expect(page).to have_content "Create a topic"
    end

    scenario "Should have content on new topic page" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      login_as(user)
      visit community_path(community)

      click_link "Create topic"

      expect(page).to have_content "Title"
      expect(page).to have_content "Initial text"
      expect(page).to have_content "Recommendations to create a topic"
      expect(page).to have_content "Do not write the topic title or whole sentences in " \
                                   "capital letters. On the internet that is considered " \
                                   "shouting. And no one likes to be yelled at."
      expect(page).to have_content "Any topic or comment that implies an illegal action " \
                                   "will be eliminated, also those that intend to " \
                                   "sabotage the spaces of the subject, everything else " \
                                   "is allowed."
      expect(page).to have_content "Enjoy this space, the voices that fill it, it's yours too."
      expect(page).to have_button("Create topic")
    end
  end

  context "Create" do
    scenario "Can create a new topic" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      login_as(user)

      visit new_community_topic_path(community)
      fill_in "topic_title", with: "New topic title"
      fill_in "topic_description", with: "Topic description"
      click_button "Create topic"

      expect(page).to have_content "New topic title"
      expect(page).to have_current_path(community_path(community))
    end

    scenario "Can not create a new topic when user not logged" do
      proposal = create(:proposal)
      community = proposal.community

      visit new_community_topic_path(community)

      expect(page).to have_content "You do not have permission to carry out the action 'new' on Topic."
    end
  end

  context "Edit" do
    scenario "Can edit a topic" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      topic = create(:topic, community: community, author: user)
      login_as(user)
      visit edit_community_topic_path(community, topic)

      fill_in "topic_title", with: "Edit topic title"
      fill_in "topic_description", with: "Edit topic description"
      click_button "Edit topic"

      expect(page).to have_content "Edit topic title"
      expect(page).to have_current_path(community_path(community))
    end

    scenario "Can not edit a topic when user logged is not an author" do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)
      user = create(:user)
      login_as(user)

      visit edit_community_topic_path(community, topic)

      expect(page).to have_content "You do not have permission to carry out the action 'edit' on Topic."
    end
  end

  context "Show" do
    scenario "Can show topic" do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)

      visit community_topic_path(community, topic)

      expect(page).to have_content community.proposal.title
      expect(page).to have_content topic.title
    end
  end

  context "Destroy" do
    scenario "Can destroy a topic" do
      user = create(:user)
      topic = create(:topic, :with_community, author: user)

      login_as(user)
      visit community_topic_path(topic.community, topic)

      click_button "Delete topic"

      expect(page).to have_content "Topic deleted successfully."
      expect(page).not_to have_content topic.title
      expect(page).to have_current_path(community_path(topic.community))
    end

    scenario "Can not destroy a topic when user logged is not an author" do
      user = create(:user)
      topic = create(:topic, :with_community)

      login_as(user)
      visit community_path(topic.community)

      expect(page).not_to have_link "Delete"
    end
  end
end
