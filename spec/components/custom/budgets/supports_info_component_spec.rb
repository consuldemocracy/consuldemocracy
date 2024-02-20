require "rails_helper"

describe Budgets::SupportsInfoComponent do
  let(:budget) { create(:budget, :selecting) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group) }
  let(:component) { Budgets::SupportsInfoComponent.new(budget) }

  it "renders when the budget is selecting with investments" do
    create_list(:budget_investment, 3, :selected, heading: heading)

    render_inline component

    expect(page).to have_selector ".supports-info"
    expect(page).to have_content "It's time to support projects!"
    expect(page).to have_link "Keep scrolling to see all ideas"
  end

  it "renders the link to see all ideas when there are investments" do
    create_list(:budget_investment, 3, :selected, heading: heading)

    render_inline component

    expect(page).to have_link "Keep scrolling to see all ideas"
  end

  it "does not render the link when there are no investments" do
    create(:budget_heading, group: group)

    render_inline component

    expect(page).not_to have_link "Keep scrolling to see all ideas"
  end
end
