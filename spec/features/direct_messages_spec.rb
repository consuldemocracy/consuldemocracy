require "rails_helper"

feature "Direct messages" do

  background do
    Setting[:direct_message_max_per_day] = 3
  end

  scenario "Create" do
    sender   = create(:user, :level_two)
    receiver = create(:user, :level_two)

    login_as(sender)
    visit user_path(receiver)

    click_link "Send private message"

    expect(page).to have_content "Send private message to #{receiver.name}"

    fill_in "direct_message_title", with: "Hey!"
    fill_in "direct_message_body",  with: "How are you doing?"
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

      expect(page).not_to have_link "Send private message"
    end

    scenario "Do not display link if direct message for user not allowed" do
      sender   = create(:user, :level_two)
      receiver = create(:user, :level_two, email_on_direct_message: false)

      login_as(sender)
      visit user_path(receiver)

      expect(page).to have_content "This user doesn't accept private messages."
      expect(page).not_to have_link "Send private message"
    end

    scenario "Unverified user" do
      sender = create(:user)
      receiver = create(:user)

      login_as(sender)
      visit new_user_direct_message_path(receiver)

      expect(page).to have_content "To send a private message verify your account"
      expect(page).not_to have_link "Send private message"
    end

    scenario "User not logged in" do
      sender = create(:user)
      receiver = create(:user)

      visit new_user_direct_message_path(receiver)

      expect(page).to have_content "You must sign in or sign up to continue."
      expect(page).not_to have_link "Send private message"
    end

    scenario "Accessing form directly" do
      sender   = create(:user, :level_two)
      receiver = create(:user, :level_two, email_on_direct_message: false)

      login_as(sender)
      visit new_user_direct_message_path(receiver)

      expect(page).to have_content("This user has decided not to receive direct messages")
      expect(page).not_to have_css("#direct_message_title")
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

    scenario "Can only send a maximum number of direct messages per day" do
      sender   = create(:user, :level_two)
      receiver = create(:user, :level_two)

      3.times { create(:direct_message, sender: sender) }

      login_as(sender)
      visit user_path(receiver)

      click_link "Send private message"

      expect(page).to have_content "Send private message to #{receiver.name}"

      fill_in "direct_message_title", with: "Hey!"
      fill_in "direct_message_body",  with: "How are you doing?"
      click_button "Send message"

      expect(page).to have_content "You have reached the maximum number of private messages per day"
      expect(page).not_to have_content "You message has been sent successfully."
    end

  end

end