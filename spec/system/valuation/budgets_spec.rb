require "rails_helper"

describe "Valuation budgets" do
  before { login_as(create(:valuator).user) }

  context "Index" do
    scenario "Displaying budgets in valuation phase" do
      budget1 = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget1)

      budget2 = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget2, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget2)

      budget3 = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget3, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget3, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget3)

      budget4 = create(:budget)

      visit valuation_budgets_path

      within "#budget_#{budget1.id}" do
        expect(page).to have_content(budget1.name)
        expect(page).to have_content "0"
      end

      within "#budget_#{budget2.id}" do
        expect(page).to have_content(budget2.name)
        expect(page).to have_content "1"
      end

      within "#budget_#{budget3.id}" do
        expect(page).to have_content(budget3.name)
        expect(page).to have_content "2"
      end

      expect(page).not_to have_content(budget4.name)
    end

    scenario "Filters by phase" do
      budget1 = create(:budget, :finished)
      budget2 = create(:budget, :drafting)
      budget3 = create(:budget, :valuating)

      visit valuation_budgets_path

      expect(page).not_to have_content(budget1.name)
      expect(page).not_to have_content(budget2.name)
      expect(page).to have_content(budget3.name)
    end

    scenario "Displays published budgets" do
      create(:budget, name: "Sports")
      create(:budget, name: "Draft", published: false)

      visit valuation_budgets_path

      expect(page).to have_content("Sports")
      expect(page).not_to have_content("Draft")
    end

    scenario "With no budgets" do
      visit valuation_budgets_path

      expect(page).to have_content "There are no budgets"
    end
  end
end
