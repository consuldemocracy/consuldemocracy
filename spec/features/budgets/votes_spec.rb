require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user, verified_at: Time.now)
  end

  feature 'Investments' do

    let(:budget)  { create(:budget, phase: "selecting") }
    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    background { login_as(@manuela) }

    feature 'Index' do

      scenario "Index shows user votes on proposals" do
        investment1 = create(:budget_investment, heading: heading)
        investment2 = create(:budget_investment, heading: heading)
        investment3 = create(:budget_investment, heading: heading)
        create(:vote, voter: @manuela, votable: investment1, vote_flag: true)

        visit budget_investments_path(budget, heading_id: heading.id)

        within("#budget-investments") do
          within("#budget_investment_#{investment1.id}_votes") do
            expect(page).to have_content "You have already supported this. Share it!"
          end

          within("#budget_investment_#{investment2.id}_votes") do
            expect(page).to_not have_content "You have already supported this. Share it!"
          end

          within("#budget_investment_#{investment3.id}_votes") do
            expect(page).to_not have_content "You have already supported this. Share it!"
          end
        end
      end

      scenario 'Create from spending proposal index', :js do
        investment = create(:budget_investment, heading: heading, budget: budget)

        visit budget_investments_path(budget, heading_id: heading.id)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this. Share it!"
        end
      end
    end

    feature 'Single spending proposal' do
      background do
        @investment = create(:budget_investment, budget: budget, heading: heading)
      end

      scenario 'Show no votes' do
        visit budget_investment_path(budget, @investment)
        expect(page).to have_content "No supports"
      end

      scenario 'Trying to vote multiple times', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click
          expect(page).to have_content "1 support"

          expect(page).to_not have_selector ".in-favor a"
        end
      end

      scenario 'Create from proposal show', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this. Share it!"
        end
      end
    end

    scenario 'Disable voting on spending proposals', :js do
      login_as(@manuela)
      budget.update(phase: "reviewing")
      investment = create(:budget_investment, budget: budget, heading: heading)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        expect(page).to_not have_css("budget_investment_#{investment.id}_votes")
      end

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).to_not have_css("budget_investment_#{investment.id}_votes")
      end
    end
  end
end
