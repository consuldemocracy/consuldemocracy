require "rails_helper"

describe Admin::BudgetHeadings::HeadingsComponent do
  it "includes group name in the message when there are no headings" do
    group = create(:budget_group, name: "Whole planet")

    render_inline Admin::BudgetHeadings::HeadingsComponent.new(group.headings)

    expect(page.text.strip).to eq "There are no headings in the Whole planet group."
    expect(page).to have_css "strong", exact_text: "Whole planet"
  end
end
