require 'rails_helper'

feature 'Vote via email' do

  context "Email" do
    scenario "Displays a show link to the top 5 proposals with a token"
    scenario "Displays a vote link to the top 5 proposals with a token"

    scenario "Token can be used for multiples proposals"
    scenario "The user can still one vote once per proposal"
  end

  context "voting Proposals via a GET link" do

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

      expect(page).to have_content "You must sign in or register to continue."

      within('.supports') do
        expect(page).to have_content "0 supports"
      end
    end

    scenario 'Unverified user is logged in'
    scenario 'Unverified user is not logged in'
    scenario 'Unverified user with invalid token'
  end

end
