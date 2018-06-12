require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting Budget::Investments' do

  before do
    Setting['feature.budgets'] = true
  end

  after do
    Setting['feature.budgets'] = nil
  end

  let(:user) { create :user }
  let(:investment) { create :budget_investment }

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @investment = create(:budget_investment)
      @comment = create(:comment, commentable: @investment)
      @budget = @investment.budget

      login_as(@manuela)
    end


    scenario 'Trying to vote multiple times', :js do
      visit budget_investment_path(@budget, @investment)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        within('.in_favor') do
          expect(page).to have_content "1"
        end

        find('.in_favor a').click
        within('.in_favor') do
          expect(page).to have_content "0"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end

end
