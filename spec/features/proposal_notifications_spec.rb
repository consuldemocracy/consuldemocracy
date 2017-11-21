require 'rails_helper'

feature 'Proposal Notifications' do

  scenario "Send a notification" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    login_as(author)
    visit root_path

    click_link "My activity"

    within("#proposal_#{proposal.id}") do
      click_link "Send notification"
    end

    fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
    fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
    click_button "Send message"

    expect(page).to have_content "Your message has been sent correctly."
    expect(page).to have_content "Thank you for supporting my proposal"
    expect(page).to have_content "Please share it with others so we can make it happen!"
  end

  scenario "Send a notification (Active voter)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    voter = create(:user, :level_two)
    create(:vote, voter: voter, votable: proposal)

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(1)
  end

  scenario "Send a notification (Follower)" do
    author = create(:user)
    proposal = create(:proposal, author: author)
    user_follower = create(:user)
    create(:follow, :followed_proposal, user: user_follower, followable: proposal)

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(1)
  end

  scenario "Send a notification (Follower and Voter)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    user_voter_follower = create(:user)
    create(:follow, :followed_proposal, user: user_voter_follower, followable: proposal)
    create(:vote, voter: user_voter_follower, votable: proposal)

    user_follower = create(:user)
    create(:follow, :followed_proposal, user: user_follower, followable: proposal)

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(2)
  end

  scenario "Send a notification (Blocked voter)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    voter = create(:user, :level_two)
    create(:vote, voter: voter, votable: proposal)
    voter.block

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(0)
  end

  scenario "Send a notification (Erased voter)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    voter = create(:user, :level_two)
    create(:vote, voter: voter, votable: proposal)
    voter.erase

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(0)
  end

  scenario "Show notifications" do
    proposal = create(:proposal)
    notification1 = create(:proposal_notification, proposal: proposal, title: "Hey guys", body: "Just wanted to let you know that...")
    notification2 = create(:proposal_notification, proposal: proposal, title: "Another update",
                                                   body: "We are almost there please share with your peoples!")

    visit proposal_path(proposal)

    expect(page).to have_content "Hey guys"
    expect(page).to have_content "Just wanted to let you know that..."

    expect(page).to have_content "Another update"
    expect(page).to have_content "We are almost there please share with your peoples!"
  end

  scenario "Message about receivers (Voters)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:vote, votable: proposal, vote_flag: true) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This message will be send to 7 people and it will be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal, anchor: 'comments'))
  end

  scenario "Message about receivers (Followers)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:follow, :followed_proposal, followable: proposal) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This message will be send to 7 people and it will be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal, anchor: 'comments'))
  end

  scenario "Message about receivers (Disctinct Followers and Voters)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:follow, :followed_proposal, followable: proposal) }
    7.times { create(:vote, votable: proposal, vote_flag: true) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This message will be send to 14 people and it will be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal, anchor: 'comments'))
  end

  scenario "Message about receivers (Same Followers and Voters)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    user_voter_follower = create(:user)
    create(:follow, :followed_proposal, user: user_voter_follower, followable: proposal)
    create(:vote, voter: user_voter_follower, votable: proposal)

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This message will be send to 1 people and it will be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal, anchor: 'comments'))
  end

  context "Permissions" do

    scenario "Link to send the message" do
      user = create(:user)
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as(author)
      visit user_path(author)

      within("#proposal_#{proposal.id}") do
        expect(page).to have_link "Send notification"
      end

      login_as(user)
      visit user_path(author)

      within("#proposal_#{proposal.id}") do
        expect(page).to_not have_link "Send message"
      end
    end

    scenario "Accessing form directly" do
      user = create(:user)
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as(user)
      visit new_proposal_notification_path(proposal_id: proposal.id)

      expect(current_path).to eq(root_path)
      expect(page).to have_content("You do not have permission to carry out the action")
    end

  end

  scenario "Error messages" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    login_as(author)

    visit new_proposal_notification_path(proposal_id: proposal.id)
    click_button "Send message"

    expect(page).to have_content error_message
  end

  context "Limits" do

    pending "Cannot send more than one notification within established interval"
    pending "use timecop to make sure notifications can be sent after time interval"

  end

end
