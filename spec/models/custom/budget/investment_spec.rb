require "rails_helper"

describe Budget::Investment do
  it "says if enough support is reached when the heading has enough_support set" do
    budget = create(:budget, :selecting)
    create(:budget_heading, budget: budget)
    investment = create(:budget_investment, budget: budget)

    expect(investment.has_required_support?).to be false
    investment.heading.required_support = 1
    expect(investment.has_required_support?).to be false
    investment.register_selection(create(:user, :level_two))
    expect(investment.has_required_support?).to be true
    investment.heading.required_support = 2
    expect(investment.has_required_support?).to be false
  end
end
