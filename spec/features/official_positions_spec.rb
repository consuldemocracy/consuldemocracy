require "rails_helper"

describe "Official positions" do
  context "Badge" do
    let(:user1) { create(:user, official_level: 1, official_position: "Employee", official_position_badge: true) }
    let(:user2) { create(:user, official_level: 0, official_position: "") }

    scenario "Comments" do
      proposal = create(:proposal)
      comment1 = create(:comment, commentable: proposal, user: user1)
      comment2 = create(:comment, commentable: proposal, user: user2)

      visit proposal_path(proposal)

      expect_badge_for("comment", comment1)
      expect_no_badge_for("comment", comment2)
    end

    context "Debates" do
      let!(:debate1) { create(:debate, author: user1) }
      let!(:debate2) { create(:debate, author: user2) }

      scenario "Index" do
        visit debates_path

        expect_badge_for("debate", debate1)
        expect_no_badge_for("debate", debate2)
      end

      scenario "Show" do
        visit debate_path(debate1)
        expect_badge_for("debate", debate1)

        visit debate_path(debate2)
        expect_no_badge_for("debate", debate2)
      end
    end

    context "Proposals" do
      let!(:proposal1) { create(:proposal, author: user1) }
      let!(:proposal2) { create(:proposal, author: user2) }

      scenario "Index" do
        visit proposals_path

        expect_badge_for("proposal", proposal1)
        expect_no_badge_for("proposal", proposal2)
      end

      scenario "Show" do
        visit proposal_path(proposal1)
        expect_badge_for("proposal", proposal1)

        visit proposal_path(proposal2)
        expect_no_badge_for("proposal", proposal2)
      end
    end
  end
end
