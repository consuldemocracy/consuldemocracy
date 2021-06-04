require "rails_helper"

describe SDGManagement::Relations::SearchComponent, type: :component do
  describe "#goal_options" do
    it "orders goals by code in the select" do
      component = SDGManagement::Relations::SearchComponent.new(label: "Search proposals")

      render_inline component
      options = page.find("#goal_code").all("option")

      expect(options[0]).to have_content "All goals"
      expect(options[1]).to have_content "1. "
      expect(options[17]).to have_content "17. "
    end
  end
end
