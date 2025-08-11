require "rails_helper"

describe "Polls" do
  context "Concerns" do
    it_behaves_like "notifiable in-app", :poll
  end

  describe "Index" do
    scenario "Shows a no open votings message when there are no polls" do
      visit polls_path

      expect(page).to have_content "There are no open votings"
      expect(page).not_to have_content "Description for open polls"
    end

    scenario "Shows active poll description for open polls when defined" do
      create(:active_poll, description: "Description for open polls")

      visit polls_path

      expect(page).to have_content "Description for open polls"

      click_link "Expired"

      expect(page).not_to have_content "Description for open polls"
    end

    scenario "Polls can be listed" do
      polls = create_list(:poll, 3, :with_image)

      visit polls_path

      polls.each do |poll|
        expect(page).to have_content(poll.name)
        expect(page).to have_css("img[alt='#{poll.image.title}']")
        expect(page).to have_link("Participate in this poll")
      end
    end

    scenario "Expired polls are ordered by ends date" do
      travel_to "01/07/2023".to_date do
        create(:poll, starts_at: "03/05/2023", ends_at: "01/06/2023", name: "Expired poll one")
        create(:poll, starts_at: "02/05/2023", ends_at: "02/06/2023", name: "Expired poll two")
        create(:poll, starts_at: "01/05/2023", ends_at: "03/06/2023", name: "Expired poll three")
        create(:poll, starts_at: "04/05/2023", ends_at: "04/06/2023", name: "Expired poll four")
        create(:poll, starts_at: "05/05/2023", ends_at: "05/06/2023", name: "Expired poll five")

        visit polls_path(filter: "expired")

        expect("Expired poll five").to appear_before("Expired poll four")
        expect("Expired poll four").to appear_before("Expired poll three")
        expect("Expired poll three").to appear_before("Expired poll two")
        expect("Expired poll two").to appear_before("Expired poll one")
      end
    end

    scenario "Proposal polls won't be listed" do
      create(:poll, related: create(:proposal))

      visit polls_path

      expect(page).to have_content "There are no open votings"
    end

    scenario "Filtering polls" do
      create(:poll, name: "Current poll")
      create(:poll, :expired, name: "Expired poll")

      visit polls_path
      expect(page).to have_content("Current poll")
      expect(page).to have_link("Participate in this poll")
      expect(page).not_to have_content("Expired poll")

      visit polls_path(filter: "expired")
      expect(page).not_to have_content("Current poll")
      expect(page).to have_content("Expired poll")
      expect(page).to have_link("Poll ended")
    end

    scenario "Current filter is properly highlighted" do
      visit polls_path
      expect(page).not_to have_link("Open")
      expect(page).to have_link("Expired")

      visit polls_path(filter: "expired")
      expect(page).to have_link("Open")
      expect(page).not_to have_link("Expired")
    end

    scenario "Already participated in a poll" do
      poll_with_question = create(:poll)
      question = create(:poll_question, :yes_no, poll: poll_with_question)

      login_as(create(:user, :level_two))
      visit polls_path

      expect(page).not_to have_css ".already-answer"

      vote_for_poll_via_web(poll_with_question, question, "Yes")

      visit polls_path

      expect(page).to have_css(".already-answer", count: 1)
      expect(page).to have_content("You already have participated in this poll")
    end
  end

  context "Show" do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    scenario "Visit path with id" do
      visit poll_path(poll.id)
      expect(page).to have_current_path(poll_path(poll.id))
    end

    scenario "Visit path with slug" do
      visit poll_path(poll.slug)
      expect(page).to have_current_path(poll_path(poll.slug))
    end

    scenario "Lists questions from proposals as well as regular ones" do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)
      expect(page).to have_content(poll.summary)
      expect(page).to have_content(poll.description)

      expect(page).to have_content(normal_question.title)
      expect(page).to have_content(proposal_question.title)
    end

    scenario "Questions appear by created at order" do
      question = create(:poll_question, poll: poll, title: "First question")
      create(:poll_question, poll: poll, title: "Second question")
      create(:poll_question, poll: poll, title: "Third question")

      question.update!(title: "First question edited")

      visit polls_path

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      visit poll_path(poll)

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")
    end

    scenario "Buttons to slide through images work back and forth" do
      question = create(:poll_question, :yes_no, poll: poll)
      create(:image, imageable: question.question_options.last, title: "The no movement")
      create(:image, imageable: question.question_options.last, title: "No movement planning")

      visit poll_path(poll)

      within(".orbit-bullets") do
        find("[data-slide='1']").click

        expect(page).to have_css ".is-active[data-slide='1']"

        find("[data-slide='0']").click

        expect(page).to have_css ".is-active[data-slide='0']"
      end
    end

    scenario "Non-logged in users" do
      create(:poll_question, :yes_no, poll: poll)

      visit poll_path(poll)

      expect(page).to have_content("You must sign in or sign up to participate")
    end

    scenario "Level 1 users" do
      poll.update!(geozone_restricted_to: [geozone])
      create(:poll_question, :yes_no, poll: poll)

      login_as(create(:user, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_content("You must verify your account in order to answer")
    end

    scenario "Level 2 users in an expired poll" do
      expired_poll = create(:poll, :expired)
      create(:poll_question, :yes_no, poll: expired_poll)

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(expired_poll)

      expect(page).to have_content("This poll has finished")
    end

    scenario "Level 2 users answering" do
      poll.update!(geozone_restricted_to: [geozone])

      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_options") do
        click_button "Vote Yes"

        expect(page).to have_button "You have voted Yes"
        expect(page).to have_button "Vote No"
      end
    end

    scenario "Level 2 users changing answer" do
      poll.update!(geozone_restricted_to: [geozone])

      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_options") do
        click_button "Yes"

        expect(page).to have_button "You have voted Yes"
        expect(page).to have_button "Vote No"

        click_button "No"

        expect(page).to have_button "Vote Yes"
        expect(page).to have_button "You have voted No"
      end
    end

    scenario "Shows SDG tags when feature is enabled" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.polls"] = true

      poll = create(:poll, sdg_goals: [SDG::Goal[1]], sdg_targets: [SDG::Target["1.1"]])

      visit poll_path(poll)

      expect(page).to have_css "img[alt='1. No Poverty']"
      expect(page).to have_content "target 1.1"
    end

    scenario "Polls with users same-geozone listed first" do
      create(:poll, geozone_restricted: true, name: "A Poll")
      create(:poll, name: "Not restricted")
      create(:poll, geozone_restricted_to: [geozone], name: "Geozone Poll")

      login_as(create(:user, :level_two, geozone: geozone))
      visit polls_path(poll)

      expect("Not restricted").to appear_before("Geozone Poll")
      expect("Geozone Poll").to appear_before("A Poll")
    end

    scenario "Level 2 users answering in a browser without javascript", :no_js do
      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two)
      login_as user
      visit poll_path(poll)

      within("#poll_question_#{question.id}_options") do
        click_button "Yes"

        expect(page).to have_button "You have voted Yes"
        expect(page).to have_button "No"
      end
    end
  end

  context "Booth & Website", :with_frozen_time do
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    scenario "Already voted on booth cannot vote on website" do
      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth, date: Date.current)
      question = create(:poll_question, :yes_no, poll: poll)
      user = create(:user, :level_two, :in_census)

      login_as(officer.user)
      visit new_officing_residence_path
      officing_verify_residence
      click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"

      within("#notice") { click_button "Close" }
      click_button "Sign out"

      expect(page).to have_content "You must sign in or register to continue."

      login_as user
      visit poll_path(poll)

      expect(page).to have_content "You have already participated in a physical booth. " \
                                   "You can not participate again."

      within("#poll_question_#{question.id}_options") do
        expect(page).to have_content("Yes")
        expect(page).to have_content("No")

        expect(page).not_to have_button "Yes"
        expect(page).not_to have_button "No"
      end
    end
  end

  context "Results and stats" do
    scenario "Show poll results and stats if enabled and poll expired" do
      poll = create(:poll, :expired, results_enabled: true, stats_enabled: true)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).to have_content("Poll results")
      expect(page).to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("Questions")

      visit stats_poll_path(poll)

      expect(page).to have_content("Participation data")
      expect(page).not_to have_content "Advanced statistics"
    end

    scenario "Advanced stats enabled" do
      poll = create(:poll, :expired, stats_enabled: true, advanced_stats_enabled: true)

      visit stats_poll_path(poll)

      expect(page).to have_content "Participation data"
      expect(page).to have_content "Advanced statistics"
    end

    scenario "Don't show poll results and stats if not enabled" do
      poll = create(:poll, :expired, results_enabled: false, stats_enabled: false)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'results' on Poll.")

      visit stats_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'stats' on Poll.")
    end

    scenario "Do not show poll results or stats to admins if disabled", :admin do
      poll = create(:poll, :expired, results_enabled: false, stats_enabled: false)

      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")
    end

    scenario "Don't show poll results and stats if is not expired" do
      poll = create(:poll, results_enabled: true, stats_enabled: true)
      user = create(:user)

      login_as user
      visit poll_path(poll)

      expect(page).not_to have_content("Poll results")
      expect(page).not_to have_content("Participation statistics")

      visit results_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'results' on Poll.")

      visit stats_poll_path(poll)
      expect(page).to have_content("You do not have permission to carry out the action 'stats' on Poll.")
    end

    scenario "Generates navigation links for polls without a slug" do
      poll = create(:poll, :expired, results_enabled: true, stats_enabled: true)
      poll.update_column(:slug, nil)

      visit poll_path(poll)

      expect(page).to have_link "Participation statistics"
      expect(page).to have_link "Poll results"

      click_link "Poll results"

      expect(page).to have_link "Information"
    end
  end
end
