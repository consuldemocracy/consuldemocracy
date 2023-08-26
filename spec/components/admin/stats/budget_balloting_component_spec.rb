require "rails_helper"

describe Admin::Stats::BudgetBallotingComponent do
  let(:budget) { create(:budget, :balloting) }
  let(:heading) { create(:budget_heading, budget: budget, name: "Main heading") }
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

  it "does not show participants per district from old budgets" do
    old_budget = create(:budget, :balloting)
    old_heading = create(:budget_heading, budget: old_budget, name: "Old Heading")
    old_investment = create(:budget_investment, :feasible, :selected, heading: old_heading)
    create(:user, ballot_lines: [old_investment])
    create(:user, ballot_lines: [old_investment])

    create(:user, ballot_lines: [investment])

    render_inline Admin::Stats::BudgetBallotingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Votes 1", normalize_ws: true
    expect(page).to have_css "p", exact_text: "Participants 1", normalize_ws: true
    expect(page).not_to have_content "Old Heading"
  end

  it "keeps votes on old budgets when there are new votes" do
    old_budget = create(:budget, :balloting)
    old_heading = create(:budget_heading, budget: old_budget, name: "Old Heading")
    old_investment = create(:budget_investment, :feasible, :selected, heading: old_heading)
    user = create(:user)

    create(:budget_ballot, user: user, budget: old_budget, investments: [old_investment])
    create(:budget_ballot, user: user, budget: budget, investments: [investment])

    render_inline Admin::Stats::BudgetBallotingComponent.new(old_budget)

    expect(page).to have_css "p", exact_text: "Votes 1", normalize_ws: true
    expect(page).to have_css "p", exact_text: "Participants 1", normalize_ws: true

    page.find ".user-count-by-heading tbody" do |table_body|
      expect(table_body).to have_css "tr", exact_text: "Old Heading 1", normalize_ws: true
    end
  end

  it "counts a participant in all headings where the participant voted" do
    another_heading = create(:budget_heading, budget: budget, name: "Another heading")
    another_investment = create(:budget_investment, :selected, heading: another_heading)

    create(:user, ballot_lines: [investment, another_investment])

    render_inline Admin::Stats::BudgetBallotingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Votes 2", normalize_ws: true
    expect(page).to have_css "p", exact_text: "Participants 1", normalize_ws: true

    page.find ".user-count-by-heading tbody" do |table_body|
      expect(table_body).to have_css "tr", exact_text: "Main heading 1", normalize_ws: true
      expect(table_body).to have_css "tr", exact_text: "Another heading 1", normalize_ws: true
    end
  end
end
