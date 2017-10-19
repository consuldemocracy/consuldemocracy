require 'rails_helper'

feature 'Poll Results' do
  scenario 'List each Poll question' do
    user = create(:user, :level_two)

    poll = create(:poll)
    question1 = create(:poll_question, poll: poll)
    answer1 = create(:poll_question_answer, question: question1, title: 'Yes')
    answer2 = create(:poll_question_answer, question: question1, title: 'No')

    question2 = create(:poll_question, poll: poll)
    answer3 = create(:poll_question_answer, question: question2, title: 'Blue')
    answer4 = create(:poll_question_answer, question: question2, title: 'Green')
    answer5 = create(:poll_question_answer, question: question2, title: 'Yellow')

    login_as user
    vote_for_poll_via_web(poll, question1, 'Yes')
    vote_for_poll_via_web(poll, question1, 'Blue')

    visit poll_results_path(poll)

    expect(page).to have_content(question1.title)
    expect(page).to have_content(question2.title)
  end
end
