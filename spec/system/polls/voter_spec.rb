require "rails_helper"

describe "Voter" do
  context "Origin", :with_frozen_time do
    let(:poll) { create(:poll, :current) }
    let(:question) { create(:poll_question, poll: poll) }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }
    let(:admin) { create(:administrator) }
    let!(:answer_yes) { create(:poll_question_answer, question: question, title: "Yes") }
    let!(:answer_no) { create(:poll_question_answer, question: question, title: "No") }

    before do
      create(:geozone, :in_census)
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth)
    end

    scenario "Voting via web - Standard" do
      user = create(:user, :level_two)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        click_link answer_yes.title
        expect(page).not_to have_link(answer_yes.title)
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("web")
    end

    scenario "Voting via web as unverified user" do
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

    scenario "Voting in booth" do
      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
        expect(page).not_to have_button("Confirm vote")
        expect(page).to have_content("Vote introduced!")
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")

      visit root_path
      click_link "Sign out"
      login_as(admin.user)
      visit admin_poll_recounts_path(poll)

      within("#total_system") do
        expect(page).to have_content "1"
      end

      within "tr", text: booth.name do
        expect(page).to have_content "1"
      end
    end

    context "The person has decided not to vote at this time" do
      before { create(:user, :in_census) }

      scenario "Show not to vote at this time button" do
        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content poll.name
        expect(page).to have_button "Confirm vote"
        expect(page).to have_content "Can vote"
        expect(page).to have_link "The person has decided not to vote at this time"
      end

      scenario "Hides not to vote at this time button if already voted" do
        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        within("#poll_#{poll.id}") do
          click_button("Confirm vote")
          expect(page).not_to have_button("Confirm vote")
          expect(page).to have_content "Vote introduced!"
          expect(page).not_to have_content "The person has decided not to vote at this time"
        end

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content "Has already participated in this poll"
        expect(page).not_to have_content "The person has decided not to vote at this time"
      end
    end

    context "Trying to vote the same poll in booth and web" do
      let!(:user) { create(:user, :in_census) }

      scenario "Trying to vote in web and then in booth" do
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

      scenario "Trying to vote in booth and then in web" do
        login_through_form_as_officer(officer.user)

        vote_for_poll_via_booth

        visit root_path
        click_link "Sign out"

        login_as user
        visit poll_path(poll)

        within("#poll_question_#{question.id}_answers") do
          expect(page).not_to have_link(answer_yes.title)
        end
        expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
        expect(Poll::Voter.count).to eq(1)

        visit root_path
        click_link "Sign out"
        login_as(admin.user)
        visit admin_poll_recounts_path(poll)

        within("#total_system") do
          expect(page).to have_content "1"
        end

        within "tr", text: booth.name do
          expect(page).to have_content "1"
        end
      end

      scenario "Trying to vote in web again" do
        login_as user
        vote_for_poll_via_web(poll, question, answer_yes.title)
        expect(Poll::Voter.count).to eq(1)

        visit poll_path(poll)

        expect(page).to have_content "You have already participated in this poll. If you vote again it will be overwritten."
        within("#poll_question_#{question.id}_answers") do
          expect(page).not_to have_link(answer_yes.title)
        end

        unfreeze_time

        click_link "Sign out"

        login_as user
        visit poll_path(poll)

        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_link(answer_yes.title)
          expect(page).to have_link(answer_no.title)
        end
      end
    end

    scenario "Voting in poll and then verifiying account" do
      user = create(:user)

      login_through_form_as_officer(officer.user)
      vote_for_poll_via_booth

      visit root_path
      click_link "Sign out"

      login_as user
      visit account_path
      click_link "Verify my account"

      verify_residence
      confirm_phone(user)

      visit poll_path(poll)

      within("#poll_question_#{question.id}_answers") do
        expect(page).not_to have_link(answer_yes.title)
      end

      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(Poll::Voter.count).to eq(1)

      visit root_path
      click_link "Sign out"
      login_as(admin.user)
      visit admin_poll_recounts_path(poll)

      within("#total_system") do
        expect(page).to have_content "1"
      end

      within "tr", text: booth.name do
        expect(page).to have_content "1"
      end
    end

    context "Side menu" do
      scenario "'Validate document' menu item with votable polls" do
        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content poll.name

        within("#side_menu") do
          expect(page).not_to have_content("Validate document")
        end

        within("#poll_#{poll.id}") do
          click_button("Confirm vote")
          expect(page).to have_content "Vote introduced!"
        end

        within("#side_menu") do
          expect(page).to have_content("Validate document")
        end
      end

      scenario "'Validate document' menu item without votable polls" do
        create(:poll_voter, poll: poll, user: create(:user, :in_census))

        login_through_form_as_officer(officer.user)

        visit new_officing_residence_path
        officing_verify_residence

        expect(page).to have_content poll.name

        within("#poll_#{poll.id}") do
          expect(page).to have_content "Has already participated in this poll"
        end

        within("#side_menu") do
          expect(page).to have_content("Validate document")
        end
      end
    end
  end
end
