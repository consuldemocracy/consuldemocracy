require "rails_helper"

describe Budgets::MapComponent do
  let(:budget) { build(:budget) }

  describe "#render?" do
    it "is rendered after the informing phase when the map feature is enabled" do
      Setting["feature.map"] = true
      budget.phase = "accepting"

      render_inline Budgets::MapComponent.new(budget)

      expect(page.first("div.map")).to have_content "located geographically"
    end

    it "is not rendered during the informing phase" do
      Setting["feature.map"] = true
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
end
