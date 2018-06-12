require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting debates' do
  let(:user)   { create :user }
  let(:debate) { create :debate }

  feature 'Voting comments' do
    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @debate = create(:debate)
      @comment = create(:comment, commentable: @debate)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        within('.in_favor') do
          expect(page).to have_content "1"
        end

        find('.in_favor a').click
        within('.in_favor') do
          expect(page).not_to have_content "2"
          expect(page).to have_content "1"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end

end
