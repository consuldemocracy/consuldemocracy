require "rails_helper"

describe "Proposal's dashboard" do
  let(:proposal) { create(:proposal, :draft) }
  before { login_as(proposal.author) }

  scenario "Dashboard has a related content section" do
    related_debate = create(:debate)
    related_proposal = create(:proposal)

    create(:related_content, parent_relationable: proposal,
                             child_relationable: related_debate, author: build(:user))

    create(:related_content, parent_relationable: proposal,
                             child_relationable: related_proposal, author: build(:user))

    visit proposal_dashboard_path(proposal)

    within("#side_menu") do
      click_link "Related content"
    end

    expect(page).to have_button("Add related content")

    within(".dashboard-related-content") do
      expect(page).to have_content("RELATED CONTENT (2)")
      expect(page).to have_selector(".related-content-title", text: "PROPOSAL")
      expect(page).to have_link related_proposal.title
      expect(page).to have_selector(".related-content-title", text: "DEBATE")
      expect(page).to have_link related_debate.title
    end
  end
end
