require "rails_helper"

describe Budgets::BudgetComponent do
  let(:budget) { create(:budget) }
  let(:heading) { create(:budget_heading, budget: budget) }
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "budget header" do
    it "shows budget name and link to help" do
      budget.update!(phase: "informing")

      render_inline Budgets::BudgetComponent.new(budget)

      page.find(".budget-header") do |header|
        expect(header).to have_content "Participatory budgets"
        expect(header).to have_content budget.name
        expect(header).to have_link "Help with participatory budgets"
      end
    end

    it "shows budget main link when defined" do
      render_inline Budgets::BudgetComponent.new(budget)

      page.find(".budget-header") do |header|
        expect(header).not_to have_css ".main-link"
      end

      budget.update!(main_link_text: "Participate now!", main_link_url: "https://consulproject.org")

      render_inline Budgets::BudgetComponent.new(budget)

      page.find(".budget-header") do |header|
        expect(header).to have_link "Participate now!", href: "https://consulproject.org", class: "main-link"
      end
    end
  end
end
