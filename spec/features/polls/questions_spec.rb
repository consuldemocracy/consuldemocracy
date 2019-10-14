require 'rails_helper'

feature 'Poll Questions' do

  scenario 'Lists questions from proposals before regular questions' do
    poll = create(:poll)
    normal_question = create(:poll_question, poll: poll)
    proposal_question = create(:poll_question, proposal: create(:proposal), poll: poll)

    visit poll_path(poll)

    expect(proposal_question.title).to appear_before(normal_question.title)
  end

  scenario 'shows the author visible name instead of a link to the author' do
    poll = create(:poll)
    question_with_author = create(:poll_question, poll: poll)
    question_with_author_visible_name = create(:poll_question, poll: poll, author_visible_name: 'potato')

    visit question_path(question_with_author)
    expect(page).to have_link(question_with_author.author.name)

    visit question_path(question_with_author_visible_name)
    expect(page).to_not have_link(question_with_author_visible_name.author.name)
    expect(page).to have_content(question_with_author_visible_name.author_visible_name)
  end

  context 'Answering' do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, geozone_restricted: true, geozone_ids: [geozone.id]) }

    scenario 'Non-logged in users' do
      question = create(:poll_question, valid_answers: 'Han Solo, Chewbacca')

      visit question_path(question)

      expect(page).to have_content('You must Sign in or Sign up to participate')
    end

    scenario 'Level 1 users' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      login_as(create(:user, geozone: geozone))
      visit question_path(question)

      expect(page).to have_content('You must verify your account in order to answer')
    end

    scenario 'Level 2 users in an poll question for a geozone which is not theirs' do

      other_poll = create(:poll, geozone_restricted: true, geozone_ids: [create(:geozone).id])
      question = create(:poll_question, poll: other_poll, valid_answers: 'Vader, Palpatine')

      login_as(create(:user, :level_two, geozone: geozone))
      visit question_path(question)

      expect(page).to have_content('This question is not available on your geozone')
    end

    scenario 'Level 2 users who can answer' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      login_as(create(:user, :level_two, geozone: geozone))
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Level 2 users who have already answered' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      user = create(:user, :level_two, geozone: geozone)
      create(:poll_answer, question: question, author: user, answer: 'Chewbacca')

      login_as user
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Level 2 users answering', :js do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Records participation', :js do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone, gender: 'female', date_of_birth: 33.years.ago)

      login_as user
      visit question_path(question)

      click_link 'Answer this question'
      click_link 'Han Solo'

      expect(page).to_not have_link('Han Solo')

      voter = poll.voters.first
      expect(voter.document_number).to eq(user.document_number)
      expect(voter.geozone_id).to eq(user.geozone_id)
      expect(voter.gender).to eq(user.gender)
      expect(voter.age).to eq(33)
      expect(voter.poll_id).to eq(poll.id)
    end

  end
end
