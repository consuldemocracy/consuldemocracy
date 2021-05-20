require "rails_helper"

describe Admin::Budgets::IndexComponent, type: :component do
  before do
    allow(ViewComponent::Base).to receive(:test_controller).and_return("Admin::BudgetsController")
    allow_any_instance_of(Admin::BudgetsController).to receive(:valid_filters).and_return(["all"])
    allow_any_instance_of(Admin::BudgetsController).to receive(:current_filter).and_return("all")
  end

  it "displays current phase zero for budgets with no current phase" do
    budget = create(:budget, :accepting, name: "Not enabled phase")
    budget.phases.accepting.update!(enabled: false)

    render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

    expect(page.find("tr", text: "Not enabled phase")).to have_content "0/8"
  end
end
