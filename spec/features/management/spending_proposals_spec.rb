require 'rails_helper'

feature 'Spending Proposals' do

  background do
    login_as_manager
  end

  context "Create" do

    scenario 'Creating spending proposals on behalf of someone' do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Create spending proposal"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end

      fill_in 'spending_proposal_title', with: 'Build a park in my neighborhood'
      fill_in 'spending_proposal_description', with: 'There is no parks here...'
      fill_in 'spending_proposal_external_url', with: 'http://moarparks.com'
      fill_in 'spending_proposal_captcha', with: correct_captcha_text
      check 'spending_proposal_terms_of_service'

      click_button 'Create'

      expect(page).to have_content 'Spending proposal created successfully.'

      expect(page).to have_content 'Build a park in my neighborhood'
      expect(page).to have_content 'There is no parks here...'
      expect(page).to have_content 'All city'
      expect(page).to have_content 'http://moarparks.com'
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(SpendingProposal.last.created_at.to_date)

      expect(current_path).to eq(management_spending_proposal_path(SpendingProposal.last))
    end

    scenario "Should not allow unverified users to create spending proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create spending proposal"

      expect(page).to have_content "User is not verified"
    end
  end

end