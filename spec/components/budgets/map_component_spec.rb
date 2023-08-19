require "rails_helper"

describe Budgets::MapComponent do
  before { Setting["feature.map"] = true }
  let(:budget) { create(:budget, :accepting) }

  describe "#render?" do
    let(:budget) { build(:budget) }

    it "is rendered after the informing phase when the map feature is enabled" do
      budget.phase = "accepting"

      render_inline Budgets::MapComponent.new(budget)

      expect(page.find(".budgets-map")).to have_content "located geographically"
    end

    it "is not rendered during the informing phase" do
      budget.phase = "informing"

      render_inline Budgets::MapComponent.new(budget)

      expect(page).not_to be_rendered
    end

    it "is not rendered when the map feature is disabled" do
      Setting["feature.map"] = false
      budget.phase = "accepting"

      render_inline Budgets::MapComponent.new(budget)

      expect(page).not_to be_rendered
    end
  end

  describe "#geozones_data" do
    it "renders data for the geozones associated with the budget" do
      create(:budget_heading, geozone: create(:geozone, color: "#0000ff"), budget: budget)
      create(:budget_heading, geozone: create(:geozone, color: "#ff0000"), budget: create(:budget))

      render_inline Budgets::MapComponent.new(budget)

      expect(page).to have_css "[data-geozones*='#0000ff']"
      expect(page).not_to have_css "[data-geozones*='#ff0000']"
    end

    it "renders empty geozone data when there are no geozones" do
      create(:budget_heading, geozone: nil, budget: budget)
      create(:budget_heading, geozone: create(:geozone, color: "#ff0000"), budget: create(:budget))

      render_inline Budgets::MapComponent.new(budget)

      expect(page).to have_css "[data-geozones='[]']"
    end
  end
end
