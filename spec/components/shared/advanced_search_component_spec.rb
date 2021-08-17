require "rails_helper"

describe Shared::AdvancedSearchComponent do
  let(:component) { Shared::AdvancedSearchComponent.new }

  context "JavaScript disabled" do
    it "renders the form" do
      render_inline component

      expect(page).to have_button "Filter"
    end

    it "hides the button to show the form" do
      render_inline component

      expect(page.find("form")).to have_button "Advanced search", visible: :hidden
    end
  end

  describe "SDG filter", controller: ProposalsController do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.proposals"] = true
    end

    it "does not render when the feature is disabled" do
      Setting["feature.sdg"] = false

      render_inline component

      expect(page).not_to have_selector "#advanced_search_goal", visible: :all
      expect(page).not_to have_selector "#advanced_search_target", visible: :all
    end

    it "does not render when the SDG process feature is disabled" do
      Setting["sdg.process.proposals"] = false

      render_inline component

      expect(page).not_to have_selector "#advanced_search_goal", visible: :all
      expect(page).not_to have_selector "#advanced_search_target", visible: :all
    end

    it "renders when both features are enabled" do
      render_inline component

      expect(page).to have_selector "#advanced_search_goal", visible: :all
      expect(page).to have_selector "#advanced_search_target", visible: :all
    end
  end
end
