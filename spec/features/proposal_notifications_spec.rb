require 'rails_helper'

feature 'Proposal Notifications' do

  scenario "Send a notification" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    login_as(author)
    visit root_path

    click_link "My activity"

    within("#proposal_#{proposal.id}") do
      click_link "Send message"
    end

    fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
    fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
    click_button "Send message"

    expect(page).to have_content "Your message has been sent correctly."
    expect(page).to have_content "Thank you for supporting my proposal"
    expect(page).to have_content "Please share it with others so we can make it happen!"
  end

  scenario "Show notifications" do
    proposal = create(:proposal)
    notification1 = create(:proposal_notification, proposal: proposal, title: "Hey guys", body: "Just wanted to let you know that...")
    notification2 = create(:proposal_notification, proposal: proposal, title: "Another update", body: "We are almost there please share with your peoples!")

    visit proposal_path(proposal)

    expect(page).to have_content "Hey guys"
    expect(page).to have_content "Just wanted to let you know that..."

    expect(page).to have_content "Another update"
    expect(page).to have_content "We are almost there please share with your peoples!"
  end

  scenario "Message about receivers" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:vote, votable: proposal, vote_flag: true) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This message will be send to 7 people and it will be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal))
  end

  context "Receivers" do

    scenario "Only send a digest to users that have the option set in their profile" do
      user1 = create(:user, email_digest: true)
      user2 = create(:user, email_digest: true)
      user3 = create(:user, email_digest: false)

      proposal = create(:proposal)

      [user1, user2, user3].each do |user|
        create(:vote, votable: proposal, voter: user)
      end

      create_proposal_notification(proposal)

      reset_mailer
      email_digest = EmailDigest.new
      email_digest.create

      expect(unread_emails_for(user1.email).size).to   eql parse_email_count(1)
      expect(unread_emails_for(user2.email).size).to   eql parse_email_count(1)
      expect(unread_emails_for(user3.email).size).to   eql parse_email_count(0)
    end

    scenario "Only send a digest to users that have voted for a proposal" do
      user1 = create(:user, email_digest: true)
      user2 = create(:user, email_digest: true)
      user3 = create(:user, email_digest: true)

      proposal = create(:proposal)

      [user1, user2].each do |user|
        create(:vote, votable: proposal, voter: user)
      end

      create_proposal_notification(proposal)

      reset_mailer
      email_digest = EmailDigest.new
      email_digest.create

      expect(unread_emails_for(user1.email).size).to   eql parse_email_count(1)
      expect(unread_emails_for(user2.email).size).to   eql parse_email_count(1)
      expect(unread_emails_for(user3.email).size).to   eql parse_email_count(0)
    end

  end
  context "Permissions" do

    scenario "Link to send the message" do
      user = create(:user)
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as(author)
      visit user_path(author)

      within("#proposal_#{proposal.id}") do
        expect(page).to have_link "Send message"
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

      expect(current_path).to eq(proposals_path)
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