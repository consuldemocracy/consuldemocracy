require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting polls' do
  let(:user) { create :user }
  let(:poll) { create(:poll, author: create(:user)) }

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @poll = create(:poll)
      @comment = create(:comment, commentable: @poll)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit poll_path(@poll)

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
