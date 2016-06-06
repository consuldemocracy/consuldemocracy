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
    click_button "Send"

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

  end

  scenario "Error messages" do
    proposal = create(:proposal)

    visit new_proposal_notification_path(proposal_id: proposal.id)
    click_button "Send"

    expect(page).to have_content error_message
  end

end