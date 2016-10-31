# coding: utf-8
require 'rails_helper'

feature 'Polls' do

  scenario 'Polls can be listed' do
    polls = create_list(:poll, 3)

    visit polls_path

    polls.each do |poll|
      expect(page).to have_link(poll.name)
    end
  end

  scenario 'Polls can be seen' do
    poll = create(:poll)
    questions = create_list(:poll_question, 5, poll: poll)

    visit poll_path(poll)
    expect(page).to have_content(poll.name)

    questions.each do |question|
      within("#poll_question_#{question.id}") do
        expect(page).to have_content(question.title)
        question.valid_answers.each do |answer|
          expect(page).to have_link(answer)
        end
      end
    end
  end
end

