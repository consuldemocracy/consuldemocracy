require 'rails_helper'

feature 'Topics' do

  context 'New' do

    scenario 'Should display disabled button to new topic page without user logged', :js do
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(page).to have_selector(".button.expanded.disabled")
    end

    scenario 'Should can access to new topic page with user logged', :js do
      proposal = create(:proposal)
      community = proposal.community
      user =  create(:user)
      login_as(user)
      visit community_path(community)

      click_link "Create topic"

      expect(page).to have_content "Create a topic"
    end

    scenario 'Should have content on new topic page', :js do
      proposal = create(:proposal)
      community = proposal.community
      user =  create(:user)
      login_as(user)
      visit community_path(community)

      click_link "Create topic"

      expect(page).to have_content "Topic Title"
      expect(page).to have_content "Description"
      expect(page).to have_content "Recommendations to create a topic"
      expect(page).to have_content "Do not write the topic title or whole sentences in capital letters. On the internet that is considered shouting. And no one likes to be yelled at."
      expect(page).to have_content "Any topic or comment that implies an illegal action will be eliminated, also those that intend to sabotage the spaces of the subject, everything else is allowed."
      expect(page).to have_content "Enjoy this space, the voices that fill it, it's yours too."
      expect(page).to have_button("Create topic")
    end

  end

  context 'Create' do

    scenario 'Should can create a new topic', :js do
      proposal = create(:proposal)
      community = proposal.community
      user =  create(:user)
      login_as(user)

      visit new_community_topic_path(community)
      fill_in "topic_title", with: "New topic title"
      fill_in "topic_description", with: "Topic description"
      click_button "Create topic"

      expect(page).to have_content "New topic title"
      expect(current_path).to eq(community_path(community))
    end

  end

  context 'Edit' do

    scenario 'Should can edit a topic' do
      proposal = create(:proposal)
      community = proposal.community
      user =  create(:user)
      topic = create(:topic, community: community, author: user)
      login_as(user)
      visit edit_community_topic_path(community, topic)

      fill_in "topic_title", with: "Edit topic title"
      fill_in "topic_description", with: "Edit topic description"
      click_button "Edit topic"

      expect(page).to have_content "Edit topic title"
      expect(current_path).to eq(community_path(community))
    end

  end

  context 'Show' do

    scenario 'Should can show topic' do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)

      visit community_topic_path(community, topic)

      expect(page).to have_content community.proposal.title
      expect(page).to have_content topic.title
    end

  end

end
