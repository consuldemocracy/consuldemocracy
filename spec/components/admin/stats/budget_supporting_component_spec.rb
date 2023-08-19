require "rails_helper"

describe Admin::Stats::BudgetSupportingComponent do
  let(:budget) { create(:budget, :balloting) }
  let(:heading) { create(:budget_heading, budget: budget, name: "Main heading") }
  let(:investment) { create(:budget_investment, :feasible, :selected, heading: heading) }

  it "shows the number of supports in investment projects" do
    another_heading = create(:budget_heading, budget: budget)
    another_investment = create(:budget_investment, heading: another_heading)

    create(:user, :level_two, votables: [investment, another_investment])
    create(:user, :level_two, votables: [investment])
    create(:user, :level_two)

    render_inline Admin::Stats::BudgetSupportingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Votes 3", normalize_ws: true
  end

  it "shows the number of users that have supported an investment project" do
    another_heading = create(:budget_heading, budget: budget)
    another_investment = create(:budget_investment, heading: another_heading)

    create(:user, :level_two, votables: [investment, another_investment])
    create(:user, :level_two, votables: [investment])
    create(:user, :level_two)

    render_inline Admin::Stats::BudgetSupportingComponent.new(budget)

    expect(page).to have_css "p", exact_text: "Participants 2", normalize_ws: true
  end

  it "shows the number of users that have supported investments projects per heading" do
    group_districts = create(:budget_group, budget: budget)
    north_district = create(:budget_heading, group: group_districts, name: "North district")
    create(:budget_heading, group: group_districts, name: "South district")

    create(:budget_investment, heading: heading, voters: [create(:user)])
    create(:budget_investment, heading: north_district, voters: [create(:user)])
    create(:budget_investment, heading: north_district, voters: [create(:user)])

    render_inline Admin::Stats::BudgetSupportingComponent.new(budget)

    page.find ".user-count-by-heading tbody" do |table_body|
      expect(table_body).to have_css "tr", exact_text: "Main heading 1", normalize_ws: true
      expect(table_body).to have_css "tr", exact_text: "North district 2", normalize_ws: true
      expect(table_body).to have_css "tr", exact_text: "South district 0", normalize_ws: true
    end
  end
end
