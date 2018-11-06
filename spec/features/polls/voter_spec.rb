require 'rails_helper'

feature "Voter" do

  context "Origin", :with_frozen_time do

    let(:poll) { create(:poll, :current) }
    let(:question) { create(:poll_question, poll: poll) }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }
    let!(:answer_yes) { create(:poll_question_answer, question: question, title: 'Yes') }
    let!(:answer_no) { create(:poll_question_answer, question: question, title: 'No') }

    background do
      create(:geozone, :in_census)
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
    end

    scenario "Voting via web - Standard", :js do
      user = create(:user, :level_two)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link answer_yes.title
        expect(page).not_to have_link(answer_yes.title)
      end

      expect(page).to have_css(".js-token-message", visible: true)
      token = find(:css, ".js-question-answer")[:href].gsub(/.+?(?=token)/, '').gsub('token=', '')

      expect(page).to have_content "You can write down this vote identifier, to check your vote on the final results: #{token}"

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting via web as unverified user", :js do
      user = create(:user, :incomplete_verification)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).not_to have_link(answer_yes.title, href: "/questions/#{question.id}/answer?answer=#{answer_yes.title}&token=")
        expect(page).not_to have_link(answer_no.title, href: "/questions/#{question.id}/answer?answer=#{answer_no.title}&token=")
      end

      expect(page).to have_content("You must verify your account in order to answer")
      expect(page).not_to have_content("You have already participated in this poll. If you vote again it will be overwritten")
    end

    scenario 'Voting in booth', :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        click_button('Confirm vote')
        expect(page).not_to have_button('Confirm vote')
        expect(page).to have_content('Vote introduced!')
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq('booth')
    end

    context "Trying to vote the same poll in booth and web" do
      let!(:user) { create(:user, :in_census) }

      scenario "Trying to vote in web and then in booth", :js do
        login_as user
        vote_for_poll_via_web(poll, question, answer_yes.title)
        expect(Poll::Voter.count).to eq(1)

        click_link "Sign out"

        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content poll.name
        expect(page).not_to have_button "Confirm vote"
        expect(page).to have_content "Has already participated in this poll"
      end

      scenario "Trying to vote in booth and then in web", :js do
        login_through_form_as_officer(officer.user)

        vote_for_poll_via_booth

        visit root_path
        click_link "Sign out"

        login_as user
        visit poll_path(poll)

        expect(page).not_to have_link(answer_yes.title)
        expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
        expect(Poll::Voter.count).to eq(1)
      end

      scenario "Trying to vote in web again", :js do
        login_as user
        vote_for_poll_via_web(poll, question, answer_yes.title)
        expect(Poll::Voter.count).to eq(1)

        visit poll_path(poll)

        expect(page).not_to have_selector('.js-token-message')

        expect(page).to have_content "You have already participated in this poll. If you vote again it will be overwritten."
        within("#poll_question_#{question.id}_answers") do
          expect(page).not_to have_link(answer_yes.title)
        end

        click_link "Sign out"

        # Time needs to pass between the moment we vote and the moment
        # we log in; otherwise the link to vote won't be available.
        # It's safe to advance one second because this test isn't
        # affected by possible date changes.
        travel 1.second do
          login_as user
          visit poll_path(poll)

          within("#poll_question_#{question.id}_answers") do
            expect(page).to have_link(answer_yes.title)
            expect(page).to have_link(answer_no.title)
          end
        end
      end
    end

    scenario "Voting in poll and then verifiying account", :js do
      user = create(:user)

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

      expect(page).not_to have_link(answer_yes.title)
      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(Poll::Voter.count).to eq(1)
    end

  end

end
