require "rails_helper"

describe "Moderate proposals" do
  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
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
