require "rails_helper"

describe "Admin proposals", :admin do
  it_behaves_like "admin_milestoneable",
                  :proposal,
                  "admin_polymorphic_path"

  context "Index" do
    scenario "Search" do
      create(:proposal, title: "Make Pluto a planet again")
      create(:proposal, title: "Build a monument to honour CONSUL developers")

      visit admin_root_path
      within("#side_menu") { click_link "Proposals" }

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).to have_content "Build a monument"

      fill_in "search", with: "Pluto"
      click_button "Search"

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).not_to have_content "Build a monument"
    end

    scenario "Select a proposal", :js do
      proposal = create(:proposal)

      visit admin_proposals_path

      within("#proposal_#{proposal.id}") { click_link "Select" }

      within("#proposal_#{proposal.id}") { expect(page).to have_link "Selected" }
      expect(proposal.reload.selected?).to be true
    end

    scenario "Unselect a proposal", :js do
      proposal = create(:proposal, :selected)

      visit admin_proposals_path

      within("#proposal_#{proposal.id}") { click_link "Selected" }

      within("#proposal_#{proposal.id}") { expect(page).to have_link "Select" }
      expect(proposal.reload.selected?).to be false
    end
  end

  context "Show" do
    scenario "View proposal" do
      create(:proposal, title: "Create a chaotic future", summary: "Chaos isn't controlled")

      visit admin_proposals_path
      click_link "Create a chaotic future"

      expect(page).to have_content "Chaos isn't controlled"
      expect(page).not_to have_content "This proposal has reached the required supports"
      expect(page).not_to have_link "Create question"
    end

    scenario "Successful proposals show create question button" do
      successful_proposals = create_successful_proposals

      visit admin_proposals_path

      successful_proposals.each do |proposal|
        visit admin_proposal_path(proposal)
        expect(page).to have_content "This proposal has reached the required supports"
        expect(page).to have_link "Add this proposal to a poll to be voted"
      end
    end

    scenario "Select a proposal" do
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)

      check "Mark as selected"
      click_button "Update proposal"

      expect(page).to have_content "Proposal updated successfully"
      expect(find_field("Mark as selected")).to be_checked
      expect(proposal.reload.selected?).to be true
    end

    scenario "Unselect a proposal" do
      proposal = create(:proposal, :selected)

      visit admin_proposal_path(proposal)

      uncheck "Mark as selected"
      click_button "Update proposal"

      expect(page).to have_content "Proposal updated successfully"
      expect(find_field("Mark as selected")).not_to be_checked
      expect(proposal.reload.selected?).to be false
    end
  end
end
