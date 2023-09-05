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

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."

      expect(page).to have_current_path(/management/)
      expect(page).to have_content "Help refugees"
      expect(page).to have_content "In summary, what we want is..."
      expect(page).to have_content "This is very important because..."
      expect(page.find(:css, "iframe")[:src]).to eq "https://www.youtube.com/embed/yRYFKcMa_Ek"
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(Date.current)
    end
  end

  context "Printing" do
    scenario "Filtering proposals to be printed" do
      worst_proposal = create(:proposal, title: "Worst proposal")
      worst_proposal.update_column(:confidence_score, 2)
      best_proposal = create(:proposal, title: "Best proposal")
      best_proposal.update_column(:confidence_score, 10)
      medium_proposal = create(:proposal, title: "Medium proposal")
      medium_proposal.update_column(:confidence_score, 5)

      login_as_manager
      click_link "Print proposals"

      expect(page).to have_link "Highest rated", class: "is-active"

      within(".proposals-list") do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      click_link "Newest"

      expect(page).to have_link "Newest", class: "is-active"

      expect(page).to have_current_path(/order=created_at/)
      expect(page).to have_current_path(/page=1/)

      within(".proposals-list") do
        expect(medium_proposal.title).to appear_before(best_proposal.title)
        expect(best_proposal.title).to appear_before(worst_proposal.title)
      end
    end
  end
end
