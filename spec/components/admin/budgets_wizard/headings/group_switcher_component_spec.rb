require "rails_helper"

describe Admin::BudgetsWizard::Headings::GroupSwitcherComponent do
  it "is not rendered for budgets with one group" do
    group = create(:budget_group, budget: create(:budget))

    render_inline Admin::BudgetsWizard::Headings::GroupSwitcherComponent.new(group)

    expect(page).not_to be_rendered
  end

  it "renders a link to switch group for budgets with two groups" do
    budget = create(:budget)
    group = create(:budget_group, budget: budget, name: "Parks")
    create(:budget_group, budget: budget, name: "Recreation")

    render_inline Admin::BudgetsWizard::Headings::GroupSwitcherComponent.new(group)

    expect(page).to have_content "Showing headings from the Parks group"
    expect(page).to have_link "Manage headings from the Recreation group."
    expect(page).not_to have_css "ul"
  end

  it "renders a menu to switch group for budgets with more than two groups" do
    budget = create(:budget)
    group = create(:budget_group, budget: budget, name: "Parks")
    create(:budget_group, budget: budget, name: "Recreation")
    create(:budget_group, budget: budget, name: "Entertainment")

    render_inline Admin::BudgetsWizard::Headings::GroupSwitcherComponent.new(group)

    expect(page).to have_content "Showing headings from the Parks group"
    expect(page).to have_button "Manage headings from a different group"

    page.find("button + ul") do |list|
      expect(list).to have_link "Recreation"
      expect(list).to have_link "Entertainment"
    end
  end
end
