require "rails_helper"

describe Moderation::Shared::TableComponent do
  include Rails.application.routes.url_helpers

  it "renders the human name of the model in a table header" do
    render_inline Moderation::Shared::TableComponent.new(Debate.none)

    expect(page).to have_css "thead th", exact_text: "Debate"
  end

  it "uses a <time> tag for the date" do
    travel_to(Time.zone.local(2019, 6, 15, 17, 20, 0)) { create(:budget_investment) }

    render_inline Moderation::Shared::TableComponent.new(Budget::Investment.all)

    expect(page).to have_css "time", exact_text: "2019-06-15"
  end

  describe "record description" do
    it "shows the description for records having one" do
      create(:proposal, description: "<p>The main changes we need here are...</p>")

      render_inline Moderation::Shared::TableComponent.new(Proposal.all)

      expect(page).to have_css ".moderation-description",
                               exact_text: "The main changes we need here are...",
                               normalize_ws: true
    end

    it "shows the body for records that don't have a description attribute" do
      create(:comment, body: "I agree!")

      render_inline Moderation::Shared::TableComponent.new(Comment.all)

      expect(page).to have_css ".moderation-description", exact_text: "I agree!", normalize_ws: true
    end
  end

  describe "flags" do
    it "shows flags for records that can be flagged" do
      create(:debate)

      render_inline Moderation::Shared::TableComponent.new(Debate.all)

      expect(page).to have_css ".flags-count"
    end

    it "does not show flags for records that cannot be flagged" do
      create(:proposal_notification)

      render_inline Moderation::Shared::TableComponent.new(ProposalNotification.all)

      expect(page).not_to have_css ".flags-count"
    end
  end

  describe "title and link" do
    it "links to the commentable when the record is a comment" do
      investment = create(:budget_investment, title: "No-parking park")
      create(:comment, commentable: investment)

      render_inline Moderation::Shared::TableComponent.new(Comment.all)

      page.find("tbody tr td:first-child") do |cell|
        expect(cell).to have_content "Investment - No-parking park"
        expect(cell).to have_link "No-parking park", href: polymorphic_path(investment, only_path: true)
      end
    end

    it "links to the proposal when the record is a proposal notification" do
      notification = create(:proposal_notification, title: "Thank you for your support!")

      render_inline Moderation::Shared::TableComponent.new(ProposalNotification.all)

      page.find("tbody tr td:first-child") do |cell|
        expect(cell).to have_link "Thank you for your support!",
                                  href: proposal_path(notification.proposal, anchor: "tab-notifications")
      end
    end

    it "links to the record otherwise" do
      debate = create(:debate, title: "More cowbell?")

      render_inline Moderation::Shared::TableComponent.new(Debate.all)

      page.find("tbody tr td:first-child") do |cell|
        expect(cell).to have_link "More cowbell?", href: polymorphic_path(debate, only_path: true)
      end
    end
  end

  describe "checkbox label" do
    it "uses the aria-label attribute with the beginning of the comment body" do
      create(:comment, body: "Probably the first option is better than the second one")

      render_inline Moderation::Shared::TableComponent.new(Comment.all)

      expect(page).to have_field "Probably the first", type: :checkbox, exact: false
    end

    it "uses an ARIA label for other records" do
      create(:budget_investment, title: "No-parking park")

      render_inline Moderation::Shared::TableComponent.new(Budget::Investment.all)

      expect(page).to have_field "No-parking park", type: :checkbox
    end
  end
end
