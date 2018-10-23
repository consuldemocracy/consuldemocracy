require 'rails_helper'

feature 'Vote via email' do

  context "Email" do

    scenario "Displays a show link and vote link to proposals" do
      user = create(:user, newsletter: true)
      proposal = create(:proposal)

      admin = create(:administrator)
      login_as(admin.user)

      visit new_admin_newsletter_path

      fill_in_newsletter_form(segment_recipient: 'All users')
      click_button "Create Newsletter"

      expect(page).to have_content "Newsletter created successfully"
      click_link "Send"

      user.reload
      show_link = proposal_path(proposal, newsletter_token: user.newsletter_token)
      vote_link = vote_proposal_path(proposal, newsletter_token: user.newsletter_token)

      email = unread_emails_for(user.email).first
      expect(email).to have_body_text(show_link)
      expect(email).to have_body_text(vote_link)
    end

  end

  context "Voting proposals via a GET link" do

    background do
      @manuela = create(:user, :verified)
      @proposal = create(:proposal)
    end

    scenario 'Verified user is logged in' do
      login_as(@manuela)
      visit proposal_path(@proposal)

      within('.supports') do
        expect(page).to have_content "No supports"
        expect(page).to have_selector ".in-favor a"
      end

      visit vote_proposal_path(@proposal)

      expect(page).to have_content "You have successfully voted this proposal"

      within('.supports') do
        expect(page).to have_content "1 support"
        expect(page).to_not have_selector ".in-favor a"
      end
    end

    scenario 'Verified user is not logged in' do
      @manuela.update(newsletter_token: "123456")

      visit vote_proposal_path(@proposal, newsletter_token: "123456")

      expect(page).to have_content "You have successfully voted this proposal"

      within('.supports') do
        expect(page).to have_content "1 support"
        expect(page).to_not have_selector ".in-favor a"
      end
    end

    scenario 'Verified user with invalid token' do
      @manuela.update(newsletter_token: "123456")

      visit vote_proposal_path(@proposal, newsletter_token: "999999")

      expect(page).to have_content("You must sign in or register to continue.")
      expect(page.current_path).to eq("/users/sign_in")
    end

    scenario 'Unverified user' do
      user = create(:user, newsletter_token: "123456")

      visit vote_proposal_path(@proposal, newsletter_token: "123456")

      expect(page).to have_content "You do not have permission to carry out the action 'vote' on proposal."
    end

  end
end
