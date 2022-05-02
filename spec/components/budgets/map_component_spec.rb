require "rails_helper"

describe Budgets::MapComponent do
  let(:budget) { build(:budget) }

  describe "#render?" do
    it "is rendered after the informing phase" do
      budget.phase = "accepting"

      render_inline Budgets::MapComponent.new(budget)

      expect(page.first("div.map")).to have_content "located geographically"
    end

    it "is not rendered during the informing phase" do
      budget.phase = "informing"

      render_inline Budgets::MapComponent.new(budget)

      expect(page).not_to be_rendered
    end
  end
end
