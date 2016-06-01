require 'rails_helper'

feature 'Proposal Notifications' do

  scenario "Send a notification" do
    noelia = create(:user)
    vega = create(:user)

    proposal = create(:proposal)
    #use correct path from my activity
    visit new_proposal_notification_path(proposal_id: proposal.id)

    fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
    fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
    click_button "Send"

    expect(page).to have_content "Your message has been sent correctly."
    expect(page).to have_content "Thank you for supporting my proposal"
    expect(page).to have_content "Please share it with others so we can make it happen!"
  end

  scenario "Error messages" do
    proposal = create(:proposal)

    visit new_proposal_notification_path(proposal_id: proposal.id)
    click_button "Send"

    expect(page).to have_content error_message
  end

end