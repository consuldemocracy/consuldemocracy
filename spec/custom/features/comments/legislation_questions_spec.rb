require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting legislation questions' do

  let(:user) { create :user, :level_two }
  let(:process) { create :legislation_process, :in_debate_phase }
  let(:legislation_question) { create :legislation_question, process: process }

  background do
    Setting['feature.legislation'] = true
  end

  after do
    Setting['feature.legislation'] = nil
  end

  feature 'Voting comments' do
    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @legislation_question = create(:legislation_question)
      @comment = create(:comment, commentable: @legislation_question)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit legislation_process_question_path(@legislation_question.process, @legislation_question)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        within('.in_favor') do
          expect(page).to have_content "1"
        end

        find('.in_favor a').click
        within('.in_favor') do
          expect(page).not_to have_content "2"
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
