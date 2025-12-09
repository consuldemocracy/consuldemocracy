require "rails_helper"

describe "Moderate proposals" do
  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_proposals_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Mark as viewed")

      visit moderation_proposals_path(filter: "all")
      expect(page).not_to have_link("All")
      expect(page).to have_link("Pending review")
      expect(page).to have_link("Mark as viewed")

      visit moderation_proposals_path(filter: "pending_flag_review")
      expect(page).to have_link("All")
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("Mark as viewed")

      visit moderation_proposals_path(filter: "with_ignored_flag")
      expect(page).to have_link("All")
      expect(page).to have_link("Pending review")
      expect(page).not_to have_link("Marked as viewed")
    end

    scenario "Filtering proposals" do
      create(:proposal, title: "Regular proposal")
      create(:proposal, :flagged, title: "Pending proposal")
      create(:proposal, :hidden, title: "Hidden proposal")
      create(:proposal, :flagged, :with_ignored_flag, title: "Ignored proposal")

      visit moderation_proposals_path(filter: "all")
      expect(page).to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")

      visit moderation_proposals_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).not_to have_content("Ignored proposal")

      visit moderation_proposals_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular proposal")
      expect(page).not_to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")
    end

    scenario "sorting proposals" do
      flagged_proposal = create(:proposal,
                                title: "Flagged proposal",
                                created_at: 1.day.ago,
                                flags_count: 5)
      flagged_new_proposal = create(:proposal,
                                    title: "Flagged new proposal",
                                    created_at: 12.hours.ago,
                                    flags_count: 3)
      newer_proposal = create(:proposal, title: "Newer proposal", created_at: Time.current)

      visit moderation_proposals_path(order: "created_at")

      expect(flagged_new_proposal.title).to appear_before(flagged_proposal.title)

      visit moderation_proposals_path(order: "flags")

      expect(flagged_proposal.title).to appear_before(flagged_new_proposal.title)

      visit moderation_proposals_path(filter: "all", order: "created_at")

      expect(newer_proposal.title).to appear_before(flagged_new_proposal.title)
      expect(flagged_new_proposal.title).to appear_before(flagged_proposal.title)

      visit moderation_proposals_path(filter: "all", order: "flags")

      expect(flagged_proposal.title).to appear_before(flagged_new_proposal.title)
      expect(flagged_new_proposal.title).to appear_before(newer_proposal.title)
    end
  end
end
