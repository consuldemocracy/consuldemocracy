require "rails_helper"

describe Admin::Budgets::TableActionsComponent, controller: Admin::BaseController do
  let(:budget) { create(:budget) }
  let(:component) { Admin::Budgets::TableActionsComponent.new(budget) }

  it "renders actions to edit and delete budget, manage investments and edit groups and manage ballots" do
    render_inline component

    expect(page).to have_link count: 4
    expect(page).to have_link "Investment projects", href: /investments/
    expect(page).to have_link "Heading groups", href: /groups/
    expect(page).to have_link "Edit", href: /edit/
    expect(page).to have_link "Preview", href: /budgets/

    expect(page).to have_button count: 2
    expect(page).to have_css "form[action*='budgets']", exact_text: "Delete"
    expect(page).to have_button "Ballots"
  end

  it "renders button to create new poll for budgets without polls" do
    render_inline component

    expect(page).to have_css "form[action*='polls'][method='post']", exact_text: "Ballots"
  end

  it "renders link to manage ballots for budgets with polls" do
    budget.poll = create(:poll, budget: budget)

    render_inline component

    expect(page).to have_link "Ballots", href: /booth_assignments/
  end
end
