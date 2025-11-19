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
  end
end
