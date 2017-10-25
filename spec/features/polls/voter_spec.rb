require 'rails_helper'

feature "Voter" do

  context "Origin" do

    let(:poll) { create(:poll, :current) }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    background do
      create(:geozone, :in_census)
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
    end

    scenario "Voting via web - Standard", :js do
      poll = create(:poll)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Yes')
      answer2 = create(:poll_question_answer, question: question, title: 'No')

      user = create(:user, :level_two)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link 'Yes'
        expect(page).to_not have_link('Yes')
      end

      find(:css, ".js-token-message").should be_visible
      token = find(:css, ".js-question-answer")[:href].gsub(/.+?(?=token)/, '').gsub('token=', '')

      expect(page).to have_content "You can write down this vote identifier, to check your vote on the final results: #{token}"

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting via web as unverified user", :js do
      poll = create(:poll)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Yes')
      answer2 = create(:poll_question_answer, question: question, title: 'No')

      user = create(:user, :incomplete_verification)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to_not have_link('Yes', href: "/questions/#{question.id}/answer?answer=Yes&token=")
        expect(page).to_not have_link('No', href: "/questions/#{question.id}/answer?answer=No&token=")
      end

      expect(page).to have_content("You must verify your account in order to answer")
      expect(page).to_not have_content("You have already participated in this poll. If you vote again it will be overwritten")
    end

    scenario "Voting in booth", :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
        expect(page).to_not have_button("Confirm vote")
        expect(page).to have_button('Wait, confirming vote...', disabled: true)
        expect(page).to have_content "Vote introduced!"
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")
    end

    context "Trying to vote the same poll in booth and web" do

      let(:poll) { create(:poll) }

      let(:question) { create(:poll_question, poll: poll) }
      let!(:answer1) { create(:poll_question_answer, question: question, title: 'Yes') }
      let!(:answer2) { create(:poll_question_answer, question: question, title: 'No') }

      let!(:user) { create(:user, :in_census) }

      scenario "Trying to vote in web and then in booth", :js do
        login_as user
        vote_for_poll_via_web(poll, question, 'Yes')
        expect(Poll::Voter.count).to eq(1)

        click_link "Sign out"

        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content poll.name
        expect(page).to_not have_button "Confirm vote"
        expect(page).to have_content "Has already participated in this poll"
      end

      scenario "Trying to vote in booth and then in web", :js do
        login_through_form_as_officer(officer.user)

        vote_for_poll_via_booth

        visit root_path
        click_link "Sign out"

        login_as user
        visit poll_path(poll)

        expect(page).to_not have_link('Yes')
        expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
        expect(Poll::Voter.count).to eq(1)
      end

      scenario "Trying to vote in web again", :js do
        login_as user
        vote_for_poll_via_web(poll, question, 'Yes')
        expect(Poll::Voter.count).to eq(1)

        visit poll_path(poll)

        expect(page).to_not have_selector('.js-token-message')

        expect(page).to have_content "You have already participated in this poll. If you vote again it will be overwritten."
        within("#poll_question_#{question.id}_answers") do
          expect(page).to_not have_link('Yes')
        end

        click_link "Sign out"

        login_as user
        visit poll_path(poll)

        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_link('Yes')
          expect(page).to have_link('No')
        end
      end
    end

    scenario "Voting in poll and then verifiying account", :js do
      user = create(:user)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Yes')
      answer2 = create(:poll_question_answer, question: question, title: 'No')

      login_through_form_as_officer(officer.user)
      vote_for_poll_via_booth

      visit root_path
      click_link "Sign out"

      login_as user
      visit account_path
      click_link 'Verify my account'

      verify_residence
      confirm_phone(user)

      visit poll_path(poll)

      expect(page).to_not have_link('Yes')
      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(Poll::Voter.count).to eq(1)
    end

  end

end
