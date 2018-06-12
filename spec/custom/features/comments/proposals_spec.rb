require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting proposals' do
  let(:user) { create :user }
  let(:proposal) { create :proposal }

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @proposal = create(:proposal)
      @comment = create(:comment, commentable: @proposal)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit proposal_path(@proposal)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
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
