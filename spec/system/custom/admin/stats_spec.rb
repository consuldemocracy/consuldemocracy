require "rails_helper"

describe "Stats", :admin do
  describe "Budget investments" do
    context "Balloting phase" do
      let(:budget) { create(:budget, :balloting) }
      let(:heading) { create(:budget_heading, budget: budget) }
      let(:investment) { create(:budget_investment, :feasible, :selected, heading: heading) }

      scenario "Do not show headings from other budgets" do
        other_heading = create(:budget_heading)
        other_investment = create(:budget_investment, :feasible, :selected, heading: other_heading)

        create(:user, ballot_lines: [investment])
        create(:user, ballot_lines: [other_investment])

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Final voting"
        end

        expect(page).to have_content heading.name
        expect(page).not_to have_content other_heading.name
      end

      scenario "Do not count removed votes" do
        create(:user, ballot_lines: [investment])
        create(:user, ballot_lines: [investment])

        Budget::Ballot::Line.last.destroy!

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Final voting"
        end

        within("#total_participants_count") do
          expect(page).to have_content "1"
        end

        within("#user_count_#{heading.slug}") do
          expect(page).to have_content "#{heading.name} 1"
        end
      end
    end
  end
end
