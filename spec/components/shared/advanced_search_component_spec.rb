require "rails_helper"

describe Shared::AdvancedSearchComponent, type: :component do
  describe "SDG filter" do
    let(:component) { Shared::AdvancedSearchComponent.new }

    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.proposals"] = true

      allow(component).to receive(:controller_path).and_return("proposals")
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
