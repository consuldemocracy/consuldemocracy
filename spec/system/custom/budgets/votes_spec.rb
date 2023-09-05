require "rails_helper"

describe "Votes" do
  let(:manuela) { create(:user, verified_at: Time.current) }

  context "Investments - Knapsack" do
    let(:budget)  { create(:budget, phase: "selecting") }
    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    before { login_as(manuela) }

    scenario "Supporting in different heading if support was removed" do
      other_heading = create(:budget_heading, group: group)

      investment = create(:budget_investment, heading: heading)
      other_investment = create(:budget_investment, heading: other_heading)

      visit budget_investment_path(budget, investment)
      within("#budget_investment_#{investment.id}") do
        accept_confirm { click_button "Support" }

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. "\
                                     "Share it!"
      end

      visit budget_investment_path(budget, other_investment)
      within("#budget_investment_#{other_investment.id}") do
        find_button("Support").click

        expect(page).to have_content "You can only support investment projects in 1 district. "\
                                     "You have already supported investments in"
      end

      visit budget_investment_path(budget, investment)
      within("#budget_investment_#{investment.id}") do
        click_button "Remove your support"

        expect(page).to have_content "No supports"
      end

      visit budget_investment_path(budget, other_investment)
      within("#budget_investment_#{other_investment.id}") do
        accept_confirm { click_button "Support" }

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. "\
                                     "Share it!"
      end
    end
  end
end
