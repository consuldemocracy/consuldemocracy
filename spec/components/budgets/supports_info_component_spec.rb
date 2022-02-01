require "rails_helper"

describe Budgets::SupportsInfoComponent do
  let(:budget) { create(:budget, :selecting) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:component) { Budgets::SupportsInfoComponent.new(budget) }

  it "renders when the budget is selecting" do
    create(:budget_heading, group: group)

    render_inline component

    expect(page).to have_selector ".supports-info"
    expect(page).to have_content "It's time to support projects!"
    expect(page).to have_link "Keep scrolling to see all ideas"
  end

  it "renders the link to see all ideas when there are multiple headings" do
    create_list(:budget_heading, 2, group: group)

    render_inline component

    expect(page).to have_link "Keep scrolling to see all ideas"
  end

  it "does not render anything when the budget is not selecting" do
    budget.update!(phase: (Budget::Phase::PHASE_KINDS - ["selecting"]).sample)

    render_inline component

    expect(page).not_to be_rendered
  end

  describe "#total_supports" do
    it "does not show supports when users are not logged in" do
      render_inline component

      expect(page).not_to have_content "So far you've supported"
    end

    context "logged users" do
      let(:user) { create(:user, :level_two) }
      before { sign_in(user) }

      it "shows supported investments" do
        heading = create(:budget_heading, budget: budget)

        render_inline component

        expect(page).to have_content "So far you've supported 0 projects."

        create(:budget_investment, :selected, heading: heading, voters: [user])

        render_inline component

        expect(page).to have_content "So far you've supported 1 project."

        create_list(:budget_investment, 3, :selected, heading: heading, voters: [user])

        render_inline component

        expect(page).to have_content "So far you've supported 4 projects."
      end

      it "does not show supports for another budget" do
        second_budget = create(:budget, phase: "selecting")
        second_component = Budgets::SupportsInfoComponent.new(second_budget)
        create_list(:budget_investment, 2, :selected, budget: budget, voters: [user])
        create_list(:budget_investment, 3, :selected, budget: second_budget, voters: [user])

        render_inline component

        expect(page).to have_content "So far you've supported 2 projects."

        sign_in(user)

        render_inline second_component

        expect(page).to have_content "So far you've supported 3 projects."
      end
    end
  end
end
