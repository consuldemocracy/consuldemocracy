require "rails_helper"

describe Budgets::Groups::ShowComponent do
  describe "#css_for_ballot_heading" do
    it "marks headings where the user has voted as active" do
      user = create(:user)
      budget = create(:budget, :balloting)
      heading = create(:budget_heading, budget: budget)
      investment = create(:budget_investment, :selected, heading: heading)
      create(:budget_ballot, budget: budget, user: user, investments: [investment])

      sign_in(user)

      render_inline Budgets::Groups::ShowComponent.new(heading.group)

      expect(page).to have_css ".is-active"
    end

    it "does not mark headings where the user hasn't voted as active" do
      user = create(:user)
      budget = create(:budget, :balloting)
      heading = create(:budget_heading, budget: budget)
      create(:budget_ballot, budget: budget, user: user)

      sign_in(user)

      render_inline Budgets::Groups::ShowComponent.new(heading.group)

      expect(page).not_to have_css ".is-active"
    end

    it "does not mark a heading as active for anonymous users" do
      budget = create(:budget, :balloting)
      heading = create(:budget_heading, budget: budget)
      investment = create(:budget_investment, :selected, heading: heading)
      create(:budget_ballot, budget: budget, user: nil, physical: true,
                             investments: [investment])

      render_inline Budgets::Groups::ShowComponent.new(heading.group)

      expect(page).not_to have_css ".is-active"
    end
  end
end
