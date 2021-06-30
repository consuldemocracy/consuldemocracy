require "rails_helper"

describe Admin::Budgets::TableActionsComponent, type: :component do
  let(:budget) { create(:budget) }
  let(:component) { Admin::Budgets::TableActionsComponent.new(budget) }

  before do
    allow(ViewComponent::Base).to receive(:test_controller).and_return("Admin::BaseController")
  end

  it "renders links to edit and delete budget, manage investments and edit groups and manage ballots" do
    render_inline component

    expect(page).to have_css "a", count: 6
    expect(page).to have_link "Investment projects", href: /investments/
    expect(page).to have_link "Heading groups", href: /groups/
    expect(page).to have_link "Edit", href: /edit/
    expect(page).to have_link "Ballots"
    expect(page).to have_link "Preview", href: /budgets/
    expect(page).to have_link "Delete", href: /budgets/
  end

  it "renders link to create new poll for budgets without polls" do
    render_inline component

    expect(page).to have_css "a[href*='polls'][data-method='post']", text: "Ballots"
  end

  it "renders link to manage ballots for budgets with polls" do
    budget.poll = create(:poll, budget: budget)

    render_inline component

    expect(page).to have_link "Ballots", href: /booth_assignments/
  end
end
