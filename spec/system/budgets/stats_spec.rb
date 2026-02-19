require "rails_helper"

describe "Stats" do
  let(:budget) { create(:budget, :finished) }

  context "Load" do
    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_stats_path("budget_slug")

      expect(page).to have_content budget.name
    end
  end

  describe "Show" do
    scenario "Back link redirects to budget page" do
      visit budget_stats_path(budget)

      expect(page).to have_link("Go back", href: budget_path(budget))
    end
  end
end
