require 'rails_helper'

feature 'Polls' do

  context '#index' do

    scenario 'Polls can be listed' do
      polls = create_list(:poll, 3)

      visit polls_path

      polls.each do |poll|
        expect(page).to have_content(poll.name)
        expect(page).to have_link("Participate in this poll")
      end
    end

    scenario 'Filtering polls' do
      create(:poll, name: "Current poll")
      create(:poll, :incoming, name: "Incoming poll")
      create(:poll, :expired, name: "Expired poll")

      visit polls_path
      expect(page).to have_content('Current poll')
      expect(page).to have_link('Participate in this poll')
      expect(page).to_not have_content('Incoming poll')
      expect(page).to_not have_content('Expired poll')

      visit polls_path(filter: 'incoming')
      expect(page).to_not have_content('Current poll')
      expect(page).to have_content('Incoming poll')
      expect(page).to have_link('More information')
      expect(page).to_not have_content('Expired poll')

      visit polls_path(filter: 'expired')
      expect(page).to_not have_content('Current poll')
      expect(page).to_not have_content('Incoming poll')
      expect(page).to have_content('Expired poll')
      expect(page).to have_link('Poll ended')
    end

    scenario "Current filter is properly highlighted" do
      visit polls_path
      expect(page).to_not have_link('Open')
      expect(page).to have_link('Incoming')
      expect(page).to have_link('Expired')

      visit polls_path(filter: 'incoming')
      expect(page).to have_link('Open')
      expect(page).to_not have_link('Incoming')
      expect(page).to have_link('Expired')

      visit polls_path(filter: 'expired')
      expect(page).to have_link('Open')
      expect(page).to have_link('Incoming')
      expect(page).to_not have_link('Expired')
    end
  end

  context 'Show' do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll) }

    scenario 'Lists questions from proposals as well as regular ones' do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)

      expect(page).to have_content(normal_question.title)
      expect(page).to have_content(proposal_question.title)
    end

    scenario 'Non-logged in users' do
      create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      visit poll_path(poll)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must Sign in or Sign up to participate')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone
      create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      login_as(create(:user, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_content('You must verify your account in order to answer')

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 2 users in an incoming poll' do
      incoming_poll = create(:poll, :incoming, geozone_restricted: true)
      incoming_poll.geozones << geozone
      create(:poll_question, poll: incoming_poll, valid_answers: 'Rey, Finn')
      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(incoming_poll)

      expect(page).to have_content('Rey')
      expect(page).to have_content('Finn')
      expect(page).to_not have_link('Rey')
      expect(page).to_not have_link('Finn')

      expect(page).to have_content('This poll has not yet started')
    end

    scenario 'Level 2 users in an expired poll' do
      expired_poll = create(:poll, :expired, geozone_restricted: true)
      expired_poll.geozones << geozone
      create(:poll_question, poll: expired_poll, valid_answers: 'Luke, Leia')
      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(expired_poll)

      expect(page).to have_content('Luke')
      expect(page).to have_content('Leia')
      expect(page).to_not have_link('Luke')
      expect(page).to_not have_link('Leia')

      expect(page).to have_content('This poll has finished')
    end

    scenario 'Level 2 users in a poll with questions for a geozone which is not theirs' do
      poll.update(geozone_restricted: true)
      poll.geozones << create(:geozone)
      create(:poll_question, poll: poll, valid_answers: 'Vader, Palpatine')
      login_as(create(:user, :level_two))

      visit poll_path(poll)

      expect(page).to have_content('Vader')
      expect(page).to have_content('Palpatine')
      expect(page).to_not have_link('Vader')
      expect(page).to_not have_link('Palpatine')
    end

    scenario 'Level 2 users reading a same-geozone poll' do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone
      create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      login_as(create(:user, :level_two, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users reading a all-geozones poll' do
      create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      login_as(create(:user, :level_two))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users who have already answered' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two)
      create(:poll_answer, question: question, author: user, answer: 'Chewbacca')

      login_as user
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
      expect(page).to have_content('Chewbacca')
    end

    scenario 'Level 2 users answering', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone
      create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)
      login_as user
      visit poll_path(poll)

      click_link 'Han Solo'

      expect(page).to_not have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

  end
end
