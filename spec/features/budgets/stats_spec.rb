require "rails_helper"

feature "Stats" do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  describe "Show" do
    describe "advanced stats" do
      let(:budget) { create(:budget, :finished) }

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
