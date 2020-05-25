require "rails_helper"

describe "Stats" do

  let(:budget)  { create(:budget, :finished) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  context "Load" do

    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_stats_path("budget_slug")

      expect(page).to have_content budget.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_stats_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_stats_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end

  end

  describe "Show" do
    describe "advanced stats" do
      scenario "advanced stats enabled" do
        budget.update(advanced_stats_enabled: true)

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
