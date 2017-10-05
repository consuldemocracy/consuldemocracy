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

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting in booth", :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      first(:button, "Confirm vote").click
      expect(page).to have_content "Vote introduced!"

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
        vote_for_poll_via_web(poll, question)

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
        expect(page).to have_content "You have already participated in a booth for this poll."
        expect(Poll::Voter.count).to eq(1)
      end
    end

  end

end
