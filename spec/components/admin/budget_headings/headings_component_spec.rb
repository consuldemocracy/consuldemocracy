require "rails_helper"

describe Admin::BudgetHeadings::HeadingsComponent, :admin do
  it "includes group name in the message when there are no headings" do
    group = create(:budget_group, name: "Whole planet")

    render_inline Admin::BudgetHeadings::HeadingsComponent.new(group.headings)

    expect(page.text.strip).to eq "There are no headings in the Whole planet group."
    expect(page).to have_css "strong", exact_text: "Whole planet"
  end

  describe "#geozone_for" do
    it "shows the geozone associated to the heading" do
      heading = create(:budget_heading, name: "Local", geozone: create(:geozone, name: "Here"))

      render_inline Admin::BudgetHeadings::HeadingsComponent.new(heading.group.headings)

      expect(page.find("tr", text: "Local")).to have_content "Here"
    end

    it "shows a generic location for headings with no associated geozone" do
      heading = create(:budget_heading, name: "Universal", geozone: nil)

      render_inline Admin::BudgetHeadings::HeadingsComponent.new(heading.group.headings)

      expect(page.find("tr", text: "Universal")).to have_content "All city"
    end
  end
end
