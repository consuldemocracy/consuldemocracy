require "rails_helper"

describe Shared::ModerationActionsComponent do
  include Rails.application.routes.url_helpers
  before { sign_in(create(:administrator).user) }

  describe "Hide link" do
    it "is shown for debates" do
      debate = create(:debate)

      render_inline Shared::ModerationActionsComponent.new(debate)

      expect(page).to have_link "Hide", href: hide_moderation_debate_path(debate)
    end

    it "is shown for proposals" do
      proposal = create(:proposal)

      render_inline Shared::ModerationActionsComponent.new(proposal)

      expect(page).to have_link "Hide", href: hide_moderation_proposal_path(proposal)
    end

    it "is shown for proposal notifications" do
      notification = create(:proposal_notification)

      render_inline Shared::ModerationActionsComponent.new(notification)

      expect(page).to have_link "Hide", href: hide_moderation_proposal_notification_path(notification)
    end

    it "is shown for comments" do
      comment = create(:comment)

      render_inline Shared::ModerationActionsComponent.new(comment)

      expect(page).to have_link "Hide", href: hide_moderation_comment_path(comment)
    end

    it "is shown for budget investments" do
      investment = create(:budget_investment)

      render_inline Shared::ModerationActionsComponent.new(investment)

      expect(page).to have_link "Hide", href: hide_moderation_budget_investment_path(investment)
    end

    it "is shown for legislation proposals" do
      proposal = create(:legislation_proposal)

      render_inline Shared::ModerationActionsComponent.new(proposal)

      expect(page).to have_link "Hide", href: hide_moderation_legislation_proposal_path(proposal)
    end
  end
end
