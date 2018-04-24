require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting Budget::Investments' do

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @investment = create(:budget_investment)
      @comment = create(:comment, commentable: @investment)
      @budget = @investment.budget

      login_as(@manuela)
    end

    # TODO : apparemment, gros pb de dependance dans le fichier originel : impossible
    # de passer le test si l'integralite du fichier n'est pas lancé en test
    xscenario 'Trying to vote multiple times', :js do
      visit budget_investment_path(@budget, @investment)
      save_and_open_page

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.in_favor a').click

        within('.in_favor') do
          expect(page).to have_content "0"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "0 votes"
      end
    end
  end

end
