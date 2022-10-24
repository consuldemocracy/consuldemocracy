require "rails_helper"

describe Admin::Budgets::IndexComponent, controller: Admin::BudgetsController do
  before do
    allow_any_instance_of(Admin::BudgetsController).to receive(:valid_filters).and_return(["all"])
    allow_any_instance_of(Admin::BudgetsController).to receive(:current_filter).and_return("all")
  end

  describe "#phase_progress_text" do
    it "displays current phase zero for budgets with no current phase" do
      budget = create(:budget, :accepting, name: "Not enabled phase")
      budget.phases.accepting.update!(enabled: false)

      render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

      expect(page.find("tr", text: "Not enabled phase")).to have_content "0/8"
    end

    it "displays phase zero out of zero for budgets with no enabled phases" do
      budget = create(:budget, name: "Without phases")
      budget.phases.each { |phase| phase.update!(enabled: false) }

      render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

      expect(page.find("tr", text: "Without phases")).to have_content "0/0"
    end
  end

  describe "#type" do
    let(:budget) { create(:budget, name: "With type") }

    it "displays 'single heading' for budgets with one heading" do
      create(:budget_heading, budget: budget)

      render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

      expect(page.find("thead")).to have_content "Type"
      expect(page.find("tr", text: "With type")).to have_content "Single heading"
    end

    it "displays 'multiple headings' for budgets with multiple headings" do
      2.times { create(:budget_heading, budget: budget) }

      render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

      expect(page.find("thead")).to have_content "Type"
      expect(page.find("tr", text: "With type")).to have_content "Multiple headings"
    end

    it "displays 'pending: no headings yet' for budgets without headings" do
      create(:budget, name: "Without headings")

      render_inline Admin::Budgets::IndexComponent.new(Budget.page(1))

      expect(page.find("thead")).to have_content "Type"
      expect(page.find("tr", text: "Without headings")).to have_content "Pending: No headings yet"
    end
  end
end
