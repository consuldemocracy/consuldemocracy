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

    scenario "Link to send the message" do
      sender   = create(:user, :level_two)

      login_as(sender)
      visit user_path(sender)

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

  context "Limits" do

    pending "Cannot send more than one notification within established interval"
    pending "use timecop to make sure notifications can be sent after time interval"

  end

end