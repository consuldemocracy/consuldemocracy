require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting topics from proposals' do
  let(:user) { create :user }
  let(:proposal) { create :proposal }

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @proposal = create(:proposal)
      @topic = create(:topic, community: @proposal.community)
      @comment = create(:comment, commentable: @topic)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit community_topic_path(@proposal.community, @topic)

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

feature 'Commenting topics from budget investments' do
  let(:user) { create :user }
  let(:investment) { create :budget_investment }

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @investment = create(:budget_investment)
      @topic = create(:topic, community: @investment.community)
      @comment = create(:comment, commentable: @topic)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit community_topic_path(@investment.community, @topic)

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
