require 'rails_helper'

feature 'Direct messages' do

  scenario "Create" do
    sender   = create(:user, :level_two)
    receiver = create(:user, :level_two)

    login_as(sender)
    visit user_path(receiver)

    click_link "Send private message"

    expect(page).to have_content "Send private message to #{receiver.name}"

    fill_in 'direct_message_title', with: "Hey!"
    fill_in 'direct_message_body',  with: "How are you doing?"
    click_button "Send message"

    expect(page).to have_content "You message has been sent successfully."
    expect(page).to have_content "Hey!"
    expect(page).to have_content "How are you doing?"
  end

  context "Permissions" do

    scenario "Do not display link to send message to myself" do
      sender = create(:user, :level_two)

      login_as(sender)
      visit user_path(sender)

      expect(page).to_not have_link "Send private message"
    end

    scenario "Do not display link if direct message for user not allowed" do
      sender   = create(:user, :level_two)
      receiver = create(:user, :level_two, email_on_direct_message: false)

      login_as(sender)
      visit user_path(receiver)

      expect(page).to have_content "This user doesn't accept private messages."
      expect(page).to_not have_link "Send private message"
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

    pending "unverified user"

  end

  scenario "Error messages" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    login_as(author)

    visit new_proposal_notification_path(proposal_id: proposal.id)
    click_button "Send message"

    expect(page).to have_content error_message
  end

end