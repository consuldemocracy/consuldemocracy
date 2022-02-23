require "rails_helper"

describe "Proposals" do
  let(:user) { create(:user, :level_two) }

  context "Create" do
    scenario "Creating proposals on behalf of someone", :with_frozen_time do
      login_managed_user(user)
      login_as_manager
      click_link "Create proposal"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content user.username.to_s
        expect(page).to have_content user.email.to_s
        expect(page).to have_content user.document_number.to_s
      end

      fill_in_new_proposal_title with: "Help refugees"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in_ckeditor "Proposal text", with: "This is very important because..."
      fill_in "External video URL", with: "https://www.youtube.com/watch?v=yRYFKcMa_Ek"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."

      expect(page).to have_current_path(/management/)
      expect(page).to have_content "Help refugees"
      expect(page).to have_content "In summary, what we want is..."
      expect(page).to have_content "This is very important because..."
      expect(page).to have_content "https://www.youtube.com/watch?v=yRYFKcMa_Ek"
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(Date.current)
    end

    scenario "Should not allow unverified users to create proposals" do
      login_managed_user(create(:user))

      login_as_manager
      click_link "Create proposal"

      expect(page).to have_content "User is not verified"
    end

    scenario "when user has not been selected we can't create a proposal" do
      Setting["feature.user.skip_verification"] = "true"
      login_as_manager

      click_link "Create proposal"

      expect(page).to have_content "To perform this action you must select a user"
      expect(page).to have_current_path management_document_verifications_path
    end
  end

  context "Show" do
    scenario "When path matches the friendly url" do
      proposal = create(:proposal)

      right_path = management_proposal_path(proposal)
      login_managed_user(user)
      login_as_manager
      visit right_path

      expect(page).to have_current_path(right_path)
    end

    scenario "When path does not match the friendly url" do
      proposal = create(:proposal)

      right_path = management_proposal_path(proposal)
      old_path = "#{management_proposals_path}/#{proposal.id}-something-else"

      login_managed_user(user)
      login_as_manager
      visit old_path

      expect(page).not_to have_current_path(old_path)
      expect(page).to have_current_path(right_path)
    end

    scenario "Successful proposal" do
      proposal = create(:proposal, :successful, title: "Success!")

      login_managed_user(user)
      login_as_manager
      visit management_proposal_path(proposal)

      expect(page).to have_content("Success!")
    end
  end

  scenario "Searching" do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")

    login_managed_user(user)
    login_as_manager
    click_link "Support proposals"

    fill_in "search", with: "what you got"
    click_button "Search"

    expect(page).to have_current_path(management_proposals_path, ignore_query: true)

    within(".proposals-list") do
      expect(page).to have_css(".proposal", count: 1)
      expect(page).to have_content(proposal1.title)
      expect(page).to have_content(proposal1.summary)
      expect(page).not_to have_content(proposal2.title)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal1)}']", text: proposal1.title)
    end
  end

  scenario "Listing" do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")

    login_managed_user(user)
    login_as_manager
    click_link "Support proposals"

    expect(page).to have_current_path(management_proposals_path)

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content user.username.to_s
      expect(page).to have_content user.email.to_s
      expect(page).to have_content user.document_number.to_s
    end

    within(".proposals-list") do
      expect(page).to have_css(".proposal", count: 2)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal1)}']", text: proposal1.title)
      expect(page).to have_content(proposal1.summary)
      expect(page).to have_css("a[href='#{management_proposal_path(proposal2)}']", text: proposal2.title)
      expect(page).to have_content(proposal2.summary)
    end
  end

  context "Voting" do
    let!(:proposal) { create(:proposal) }

    scenario "Voting proposals on behalf of someone in index view" do
      login_managed_user(user)
      login_as_manager
      click_link "Support proposals"

      within(".proposals-list") do
        click_button "Support"
        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this proposal. Share it!"
      end

      expect(page).to have_current_path(management_proposals_path)
    end

    scenario "Voting proposals on behalf of someone in show view" do
      login_managed_user(user)
      login_as_manager
      click_link "Support proposals"

      within(".proposals-list") { click_link proposal.title }
      expect(page).to have_content proposal.code
      within("#proposal_#{proposal.id}_votes") { click_button "Support" }

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this proposal. Share it!"
      expect(page).to have_content "Following"
      expect(page).to have_current_path(management_proposal_path(proposal))
    end

    scenario "Should not allow unverified users to vote proposals" do
      login_managed_user(create(:user))

      login_as_manager
      click_link "Support proposals"

      expect(page).to have_content "User is not verified"
    end

    scenario "when user has not been selected we can't support proposals" do
      Setting["feature.user.skip_verification"] = "true"
      login_as_manager

      click_link "Support proposals"

      expect(page).to have_content "To perform this action you must select a user"
      expect(page).to have_current_path management_document_verifications_path
    end
  end

  context "Printing" do
    scenario "Printing proposals" do
      6.times { create(:proposal) }

      login_as_manager
      click_link "Print proposals"

      expect(page).to have_css(".proposal", count: 5)
      expect(page).to have_css("a[href='javascript:window.print();']", text: "Print")
    end

    scenario "Filtering proposals to be printed" do
      worst_proposal = create(:proposal, title: "Worst proposal")
      worst_proposal.update_column(:confidence_score, 2)
      best_proposal = create(:proposal, title: "Best proposal")
      best_proposal.update_column(:confidence_score, 10)
      medium_proposal = create(:proposal, title: "Medium proposal")
      medium_proposal.update_column(:confidence_score, 5)

      login_as_manager
      click_link "Print proposals"

      expect(page).to have_link "highest rated", class: "is-active"

      within(".proposals-list") do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      click_link "newest"

      expect(page).to have_link "newest", class: "is-active"

      expect(page).to have_current_path(/order=created_at/)
      expect(page).to have_current_path(/page=1/)

      within(".proposals-list") do
        expect(medium_proposal.title).to appear_before(best_proposal.title)
        expect(best_proposal.title).to appear_before(worst_proposal.title)
      end
    end

    scenario "when user has not been selected we can't support a proposal" do
      create(:proposal)
      Setting["feature.user.skip_verification"] = "true"
      login_as_manager

      click_link "Print proposals"
      within ".proposals-list" do
        click_button "Support"
      end

      expect(page).to have_content "To perform this action you must select a user"
      expect(page).to have_current_path management_document_verifications_path
    end
  end
end
