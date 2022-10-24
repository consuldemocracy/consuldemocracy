require "rails_helper"

describe "Stats" do
  let(:budget)  { create(:budget, :finished) }
  let(:heading) { create(:budget_heading, budget: budget, price: 1000) }

  context "Load" do
    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_stats_path("budget_slug")

      expect(page).to have_content budget.name
    end
  end

  describe "Show" do
    describe "advanced stats" do
      scenario "advanced stats enabled" do
        budget.update!(advanced_stats_enabled: true)

        visit budget_stats_path(budget)

        expect(page).to have_content "Advanced statistics"
      end

      scenario "advanced stats disabled" do
        visit budget_stats_path(budget)

        expect(page).not_to have_content "Advanced statistics"
      end
    end
  end
end
