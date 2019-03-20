require "rails_helper"

feature "Stats" do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  describe "Show" do

    it "is not accessible if supports phase is not finished" do
      budget.update(phase: "selecting")

      visit budget_stats_path(budget.id)
      expect(page).to have_content "You do not have permission to carry out the action "\
                                   "'read_stats' on budget."
    end

    it "is accessible if supports phase is finished" do
      budget.update(phase: "valuating")

      visit budget_stats_path(budget.id)
      expect(page).to have_content "Stats"
    end

  end

end
