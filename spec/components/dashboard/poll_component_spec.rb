require "rails_helper"

describe Dashboard::PollComponent do
  include Rails.application.routes.url_helpers

  let(:proposal) { create(:proposal, :draft) }

  before { sign_in(proposal.author) }

  describe "Poll card content" do
    describe "actions visibility" do
      it "shows results link for current polls" do
        current = create(:poll, related: proposal)

        render_inline Dashboard::PollComponent.new(current)

        expect(page).not_to have_link "Edit survey"
        expect(page).to have_link "View results", href: results_proposal_poll_path(proposal, current)
      end

      it "shows results link for expired polls" do
        expired = create(:poll, :expired, related: proposal)

        render_inline Dashboard::PollComponent.new(expired)

        expect(page).not_to have_link "Edit survey"
        expect(page).to have_link "View results", href: results_proposal_poll_path(proposal, expired)
      end

      it "shows edit link for upcoming polls" do
        upcoming = create(:poll, related: proposal, starts_at: 1.week.from_now)

        render_inline Dashboard::PollComponent.new(upcoming)

        expect(page).to have_link "Edit survey", href: edit_proposal_dashboard_poll_path(proposal, upcoming)
        expect(page).not_to have_link "View results"
      end
    end

    it "renders poll title and dates" do
      expired = create(:poll, :expired, related: proposal)

      render_inline Dashboard::PollComponent.new(expired)

      expect(page).to have_content I18n.l(expired.starts_at.to_date)
      expect(page).to have_content I18n.l(expired.ends_at.to_date)
      expect(page).to have_link expired.title
      expect(page).to have_link expired.title, href: proposal_poll_path(proposal, expired)
    end
  end
end
