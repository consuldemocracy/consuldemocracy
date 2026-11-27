require "rails_helper"

describe Proposals::FormComponent do
  include Rails.application.routes.url_helpers

  before { sign_in(create(:user)) }

  describe "map" do
    it "renders a button to remove the map marker" do
      Setting["feature.map"] = true

      render_inline Proposals::FormComponent.new(Proposal.new, url: proposals_path)

      expect(page).to have_button "Remove map marker"
    end

    it "gives map instructions an id distinct from tag instructions" do
      Setting["feature.map"] = true
      create(:tag, :category, name: "Health")

      render_inline Proposals::FormComponent.new(Proposal.new, url: proposals_path)

      expect(page).to have_css(
        "#map-location-help-text",
        count: 1,
        exact_text: "Navigate the map to the location and place the marker."
      )
      expect(page).to have_css(
        "#tag-list-help-text",
        count: 1,
        exact_text: "Tag this proposal. You can choose from proposed categories or add your own"
      )

      describedby = page.find("#proposal_tag_list")["aria-describedby"].to_s.split

      expect(describedby).not_to include("map-location-help-text")
    end
  end
end
