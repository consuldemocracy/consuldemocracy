require "rails_helper"

describe Budgets::Stats::AdvancedStatsComponent do
  it "is rendered with advanced stats enabled" do
    stats = Budget::Stats.new(Budget.new(advanced_stats_enabled: true))

    render_inline Budgets::Stats::AdvancedStatsComponent.new(stats)

    expect(page).to have_content "Advanced statistics"
  end

  it "is not rendered with advanced stats disabled" do
    stats = Budget::Stats.new(Budget.new)

    render_inline Budgets::Stats::AdvancedStatsComponent.new(stats)

    expect(page).not_to be_rendered
  end

  context "budget with headings" do
    let(:budget) { create(:budget, :finished, advanced_stats_enabled: true) }
    let(:heading) { create(:budget_heading, budget: budget, name: "Software development") }
    before { create(:budget_investment, heading: heading) }

    it "renders a table with headings" do
      stats = Budget::Stats.new(budget)

      render_inline Budgets::Stats::AdvancedStatsComponent.new(stats)

      expect(page).to have_table with_rows: [{ "Heading" => "Software development",
                                               "Investment proposals sent" => "1" }]
    end
  end
end
