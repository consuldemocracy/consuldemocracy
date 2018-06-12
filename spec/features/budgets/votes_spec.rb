require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user, verified_at: Time.current)
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
            expect(page).to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment2.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment3.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end
        end
      end

      scenario 'Create from spending proposal index', :js do
        investment = create(:budget_investment, heading: heading, budget: budget)

        visit budget_investments_path(budget, heading_id: heading.id)

        within('.supports') do
          accept_confirm { find('.in-favor a').click }

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
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
          accept_confirm { find('.in-favor a').click }
          expect(page).to have_content "1 support"

          expect(page).not_to have_selector ".in-favor a"
        end
      end

      scenario 'Create from proposal show', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          accept_confirm { find('.in-favor a').click }

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end
      end
    end

    scenario 'Disable voting on spending proposals', :js do
      login_as(@manuela)
      budget.update(phase: "reviewing")
      investment = create(:budget_investment, budget: budget, heading: heading)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end
    end

    context "Voting in multiple headings of a single group" do

      let(:new_york) { heading }
      let(:san_francisco) { create(:budget_heading, group: group) }
      let(:third_heading) { create(:budget_heading, group: group) }

      let!(:new_york_investment) { create(:budget_investment, heading: new_york) }
      let!(:san_francisco_investment) { create(:budget_investment, heading: san_francisco) }
      let!(:third_heading_investment) { create(:budget_investment, heading: third_heading) }

      background do
        group.update(max_votable_headings: 2)
      end

      scenario "From Index", :js do
        visit budget_investments_path(budget, heading_id: new_york.id)

        within("#budget_investment_#{new_york_investment.id}") do
          accept_confirm { find('.in-favor a').click }

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end

        visit budget_investments_path(budget, heading_id: san_francisco.id)

        within("#budget_investment_#{san_francisco_investment.id}") do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end

        visit budget_investments_path(budget, heading_id: third_heading.id)

        within("#budget_investment_#{third_heading_investment.id}") do
          find('.in-favor a').click

          expect(page).to have_content "You can only support investment projects in 2 districts"

          expect(page).not_to have_content "1 support"
          expect(page).not_to have_content "You have already supported this investment project. Share it!"
        end
      end

      scenario "From show", :js do
        visit budget_investment_path(budget, new_york_investment)

        accept_confirm { find('.in-favor a').click }
        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. Share it!"

        visit budget_investment_path(budget, san_francisco_investment)

        find('.in-favor a').click
        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. Share it!"

        visit budget_investment_path(budget, third_heading_investment)

        find('.in-favor a').click
        expect(page).to have_content "You can only support investment projects in 2 districts"

        expect(page).not_to have_content "1 support"
        expect(page).not_to have_content "You have already supported this investment project. Share it!"
      end

    end
  end
end
