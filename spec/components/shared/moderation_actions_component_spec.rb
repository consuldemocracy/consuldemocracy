require "rails_helper"

describe Shared::ModerationActionsComponent do
  include Rails.application.routes.url_helpers

  before { sign_in(create(:administrator).user) }

  describe "Hide button" do
    it "is shown for debates" do
      debate = create(:debate)

      render_inline Shared::ModerationActionsComponent.new(debate)

      page.find("form[action='#{hide_moderation_debate_path(debate)}']") do
        expect(page).to have_button "Hide"
      end
    end

    it "is shown for proposals" do
      proposal = create(:proposal)

      render_inline Shared::ModerationActionsComponent.new(proposal)

      page.find("form[action='#{hide_moderation_proposal_path(proposal)}']") do
        expect(page).to have_button "Hide"
      end
    end

    it "is shown for proposal notifications" do
      notification = create(:proposal_notification)

      render_inline Shared::ModerationActionsComponent.new(notification)

      page.find("form[action='#{hide_moderation_proposal_notification_path(notification)}']") do
        expect(page).to have_button "Hide"
      end
    end

    it "is shown for comments" do
      comment = create(:comment)

      render_inline Shared::ModerationActionsComponent.new(comment)

      page.find("form[action='#{hide_moderation_comment_path(comment)}']") do
        expect(page).to have_button "Hide"
      end
    end

    it "is shown for budget investments" do
      investment = create(:budget_investment)

      render_inline Shared::ModerationActionsComponent.new(investment)

      page.find("form[action='#{hide_moderation_budget_investment_path(investment)}']") do
        expect(page).to have_button "Hide"
      end
    end

    it "is shown for legislation proposals" do
      proposal = create(:legislation_proposal)

      render_inline Shared::ModerationActionsComponent.new(proposal)

      page.find("form[action='#{hide_moderation_legislation_proposal_path(proposal)}']") do
        expect(page).to have_button "Hide"
      end
    end

    context "when moderator is the author" do
      let(:moderator) { create(:moderator) }

      before { sign_in(moderator.user) }

      it "does not show hide button for debates" do
        debate = create(:debate, author: moderator.user)

        render_inline Shared::ModerationActionsComponent.new(debate)

        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end

      it "does not show hide button for proposals" do
        proposal = create(:proposal, author: moderator.user)

        render_inline Shared::ModerationActionsComponent.new(proposal)

        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end

      it "does not show hide button for budget investments" do
        investment = create(:budget_investment, author: moderator.user)

        render_inline Shared::ModerationActionsComponent.new(investment)

        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end

      it "does not show hide button for legislation proposals" do
        proposal = create(:legislation_proposal, author: moderator.user)

        render_inline Shared::ModerationActionsComponent.new(proposal)

        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end

      it "does not show hide button for proposal notifications" do
        proposal = create(:proposal, author: moderator.user)
        notification = create(:proposal_notification, proposal: proposal)

        render_inline Shared::ModerationActionsComponent.new(notification)

        expect(page).not_to have_button "Hide"
        expect(page).not_to have_button "Block author"
      end
    end
  end
end
