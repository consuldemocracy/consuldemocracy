require 'rails_helper'

feature "Voter" do

  context "Origin" do

    scenario "Voting via web", :js do
      poll = create(:poll)
      question = create(:poll_question, poll: poll, valid_answers: 'Yes, No')
      user = create(:user, :level_two)

      login_as user
      visit question_path(question)

      click_link 'Answer this question'
      click_link 'Yes'

      expect(page).to_not have_link('Yes')
      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting in booth", :js do
      user  = create(:user, :in_census)
      create(:geozone, :in_census)

      poll = create(:poll)
      officer = create(:poll_officer)

      ba = create(:poll_booth_assignment, poll: poll)
      create(:poll_officer_assignment, officer: officer, booth_assignment: ba)

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
      let(:question) { create(:poll_question, poll: poll, valid_answers: 'Yes, No') }
      let!(:user) { create(:user, :in_census) }

      let(:officer) { create(:poll_officer) }
      let(:ba) { create(:poll_booth_assignment, poll: poll) }
      let!(:oa) { create(:poll_officer_assignment, officer: officer, booth_assignment: ba) }

      scenario "Trying to vote in web and then in booth", :js do
        login_as user
        vote_for_poll_via_web

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
        visit question_path(question)

        click_link 'Answer this question'

        expect(page).to_not have_link('Yes')
        expect(page).to have_content "You have already participated in a booth for this poll."
        expect(Poll::Voter.count).to eq(1)
      end
    end

  end

end