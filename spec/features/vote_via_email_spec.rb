require 'rails_helper'

feature 'Vote via email' do

  context "Voting proposals via a GET link" do

    background do
      @manuela = create(:user, :verified)
      @proposal = create(:proposal)
    end

    scenario 'Verified user is logged in' do
      @manuela.update(newsletter_token: "123456")

      login_as(@manuela)
      visit proposal_path(@proposal)

      within('.supports') do
        expect(page).to have_content "No supports"
        expect(page).to have_selector ".in-favor a"
      end

      visit vote_proposal_path(@proposal, newsletter_token: "123456")

      expect(page).to have_content "You have successfully voted this proposal"

      within('.supports') do
        expect(page).to have_content "1 support"
        expect(page).to_not have_selector ".in-favor a"
      end

      expect_to_not_be_signed_in
    end

    scenario 'Verified user is not logged in' do
      @manuela.update(newsletter_token: "123456")

      visit vote_proposal_path(@proposal, newsletter_token: "123456")

      expect(page).to have_content "You have successfully voted this proposal"

      within('.supports') do
        expect(page).to have_content "1 support"
        expect(page).to_not have_selector ".in-favor a"
      end

      expect_to_not_be_signed_in
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

      expect(page).to have_content "You must sign in or register to continue"
      expect(page.current_path).to eq("/users/sign_in")
    end

  end
end
