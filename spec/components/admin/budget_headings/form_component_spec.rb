require "rails_helper"

describe Admin::BudgetHeadings::FormComponent do
  describe "geozone field" do
    let(:heading) { create(:budget_heading) }
    let(:component) { Admin::BudgetHeadings::FormComponent.new(heading, path: "/", action: nil) }
    before { Setting["feature.map"] = true }

    it "is shown when the map feature is enabled" do
      render_inline component

      expect(page).to have_select "Scope of operation"
    end

    it "is not shown when the map feature is disabled" do
      Setting["feature.map"] = false

      render_inline component

      expect(page).not_to have_select "Scope of operation"
    end

    it "includes all existing geozones plus an option for all city" do
      create(:geozone, name: "Under the sea")
      create(:geozone, name: "Above the skies")

      render_inline component

      expect(page).to have_select "Scope of operation",
                                  options: ["All city", "Under the sea", "Above the skies"]
    end
  end
end
