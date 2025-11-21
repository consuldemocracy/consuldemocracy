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
end
