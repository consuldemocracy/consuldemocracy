require "rails_helper"

feature "Official positions" do

  context "Badge" do

    background do
      @user1 = create(:user, official_level: 1, official_position: "Employee", official_position_badge: true)
      @user2 = create(:user, official_level: 0, official_position: "")
    end

    scenario "Comments" do
      proposal = create(:proposal)
      comment1 = create(:comment, commentable: proposal, user: @user1)
      comment2 = create(:comment, commentable: proposal, user: @user2)

      visit proposal_path(proposal)

      expect_badge_for("comment", comment1)
      expect_no_badge_for("comment", comment2)
    end

    context "Debates" do

      background do
        @debate1 = create(:debate, author: @user1)
        @debate2 = create(:debate, author: @user2)
      end

      scenario "Index" do
        visit debates_path

        expect_badge_for("debate", @debate1)
        expect_no_badge_for("debate", @debate2)
      end

      scenario "Show" do
        visit debate_path(@debate1)
        expect_badge_for("debate", @debate1)

        visit debate_path(@debate2)
        expect_no_badge_for("debate", @debate2)
      end

    end

    context "Proposals" do

      background do
        @proposal1 = create(:proposal, author: @user1)
        @proposal2 = create(:proposal, author: @user2)

        create_featured_proposals
      end

      scenario "Index" do
        visit proposals_path

        expect_badge_for("proposal", @proposal1)
        expect_no_badge_for("proposal", @proposal2)
      end

      scenario "Show" do
        visit proposal_path(@proposal1)
        expect_badge_for("proposal", @proposal1)

        visit proposal_path(@proposal2)
        expect_no_badge_for("proposal", @proposal2)
      end

    end

    context "Spending proposals" do

      background do
        Setting["feature.spending_proposals"] = true
        @spending_proposal1 = create(:spending_proposal, author: @user1)
        @spending_proposal2 = create(:spending_proposal, author: @user2)
      end

      after do
        Setting["feature.spending_proposals"] = nil
      end

      scenario "Index" do
        visit spending_proposals_path

        expect_badge_for("spending_proposal", @spending_proposal1)
        expect_no_badge_for("spending_proposal", @spending_proposal2)
      end

      scenario "Show" do
        visit spending_proposal_path(@spending_proposal1)
        expect_badge_for("spending_proposal", @spending_proposal1)

        visit spending_proposal_path(@spending_proposal2)
        expect_no_badge_for("spending_proposal", @spending_proposal2)
      end

    end
  end
end
