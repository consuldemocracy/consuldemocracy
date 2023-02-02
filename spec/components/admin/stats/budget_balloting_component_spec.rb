require "rails_helper"

describe Admin::Stats::BudgetBallotingComponent do
  let(:budget) { create(:budget, :balloting) }
  let(:heading) { create(:budget_heading, budget: budget) }
  let(:investment) { create(:budget_investment, :feasible, :selected, heading: heading) }

  it "shows the number of votes in investment projects" do
    investment_2 = create(:budget_investment, :feasible, :selected, budget: budget)

    create(:user, ballot_lines: [investment, investment_2])
    create(:user, ballot_lines: [investment_2])

    render_inline Admin::Stats::BudgetBallotingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Votes 3", normalize_ws: true
  end

  it "shows the number of users that have voted a investment project" do
    create(:user, ballot_lines: [investment])
    create(:user, ballot_lines: [investment])
    create(:user)

    render_inline Admin::Stats::BudgetBallotingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Participants 2", normalize_ws: true
  end
end
