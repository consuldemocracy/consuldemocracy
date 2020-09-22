require "rails_helper"

describe "Proposals" do
  before do
    login_as_manager
  end

  context "Create" do
    scenario "Creating proposals on behalf of someone" do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Create proposal"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content user.username.to_s
        expect(page).to have_content user.email.to_s
        expect(page).to have_content user.document_number.to_s
      end

      fill_in "Proposal title", with: "Help refugees"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in "Proposal text", with: "This is very important because..."
      fill_in "proposal_video_url", with: "https://www.youtube.com/watch?v=yRYFKcMa_Ek"
      check "proposal_terms_of_service"

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."

      expect(page).to have_content "Help refugees"
      expect(page).to have_content "In summary, what we want is..."
      expect(page).to have_content "This is very important because..."
      expect(page).to have_content "https://www.youtube.com/watch?v=yRYFKcMa_Ek"
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)

      expect(page).to have_current_path(management_proposal_path(Proposal.last))
    end

    scenario "Should not allow unverified users to create proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create proposal"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Show" do
    scenario "When path matches the friendly url" do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      right_path = management_proposal_path(proposal)
      visit right_path

      expect(page).to have_current_path(right_path)
    end

    scenario "When path does not match the friendly url" do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      right_path = management_proposal_path(proposal)
      old_path = "#{management_proposals_path}/#{proposal.id}-something-else"
      visit old_path

      expect(page).not_to have_current_path(old_path)
      expect(page).to have_current_path(right_path)
    end

    scenario "Successful proposal", :js do
      proposal = create(:proposal, :successful, title: "Success!")

      login_managed_user(create(:user, :level_two))
      visit management_proposal_path(proposal)

      expect(page).to have_content("Success!")
    end
  end

  scenario "Searching" do
    proposal1 = create(:proposal, title: "Show me what you got")
    proposal2 = create(:proposal, title: "Get Schwifty")

    user = create(:user, :level_two)
    login_managed_user(user)

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

    user = create(:user, :level_two)
    login_managed_user(user)

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

    scenario "Voting proposals on behalf of someone in index view", :js do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      within(".proposals-list") do
        click_link("Support")
        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this proposal. Share it!"
      end

      expect(page).to have_current_path(management_proposals_path)
    end

    scenario "Voting proposals on behalf of someone in show view", :js do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      within(".proposals-list") { click_link proposal.title }
      expect(page).to have_content proposal.code
      within("#proposal_#{proposal.id}_votes") { click_link("Support") }

      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this proposal. Share it!"
      expect(page).to have_content "Following"
      expect(page).to have_current_path(management_proposal_path(proposal))
    end

    scenario "Should not allow unverified users to vote proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Support proposals"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Printing" do
    scenario "Printing proposals" do
      6.times { create(:proposal) }

      click_link "Print proposals"

      expect(page).to have_css(".proposal", count: 5)
      expect(page).to have_css("a[href='javascript:window.print();']", text: "Print")
    end

    scenario "Filtering proposals to be printed", :js do
      worst_proposal = create(:proposal, title: "Worst proposal")
      worst_proposal.update_column(:confidence_score, 2)
      best_proposal = create(:proposal, title: "Best proposal")
      best_proposal.update_column(:confidence_score, 10)
      medium_proposal = create(:proposal, title: "Medium proposal")
      medium_proposal.update_column(:confidence_score, 5)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Print proposals"

      expect(page).to have_selector(".js-order-selector[data-order='confidence_score']")

      within(".proposals-list") do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      select "newest", from: "order-selector"

      expect(page).to have_selector(".js-order-selector[data-order='created_at']")

      expect(current_url).to include("order=created_at")
      expect(current_url).to include("page=1")

      within(".proposals-list") do
        expect(medium_proposal.title).to appear_before(best_proposal.title)
        expect(best_proposal.title).to appear_before(worst_proposal.title)
      end
    end
  end
end
