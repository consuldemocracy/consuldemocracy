require "rails_helper"

describe "Stats" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
    visit root_path
  end

  context "Summary" do

    scenario "General" do
      create(:debate)
      2.times { create(:proposal) }
      3.times { create(:comment, commentable: Debate.first) }
      4.times { create(:visit) }

      visit admin_stats_path

      expect(page).to have_content "Debates 1"
      expect(page).to have_content "Proposals 2"
      expect(page).to have_content "Comments 3"
      expect(page).to have_content "Visits 4"
    end

    scenario "Votes" do
      debate = create(:debate)
      create(:vote, votable: debate)

      proposal = create(:proposal)
      2.times { create(:vote, votable: proposal) }

      comment = create(:comment)
      3.times { create(:vote, votable: comment) }

      visit admin_stats_path

      expect(page).to have_content "Debate votes 1"
      expect(page).to have_content "Proposal votes 2"
      expect(page).to have_content "Comment votes 3"
      expect(page).to have_content "Total votes 6"
    end

  end

  context "Users" do

    scenario "Summary" do
      1.times { create(:user, :level_three) }
      2.times { create(:user, :level_two) }
      3.times { create(:user) }

      visit admin_stats_path

      expect(page).to have_content "Level three users 1"
      expect(page).to have_content "Level two users 2"
      expect(page).to have_content "Verified users 3"
      expect(page).to have_content "Unverified users 4"
      expect(page).to have_content "Total users 7"
    end

    scenario "Do not count erased users" do
      1.times { create(:user, :level_three, erased_at: Time.current) }
      2.times { create(:user, :level_two, erased_at: Time.current) }
      3.times { create(:user, erased_at: Time.current) }

      visit admin_stats_path

      expect(page).to have_content "Level three users 0"
      expect(page).to have_content "Level two users 0"
      expect(page).to have_content "Verified users 0"
      expect(page).to have_content "Unverified users 1"
      expect(page).to have_content "Total users 1"
    end

    scenario "Do not count hidden users" do
      1.times { create(:user, :level_three, hidden_at: Time.current) }
      2.times { create(:user, :level_two, hidden_at: Time.current) }
      3.times { create(:user, hidden_at: Time.current) }

      visit admin_stats_path

      expect(page).to have_content "Level three users 0"
      expect(page).to have_content "Level two users 0"
      expect(page).to have_content "Verified users 0"
      expect(page).to have_content "Unverified users 1"
      expect(page).to have_content "Total users 1"
    end

    scenario "Level 2 user Graph" do
      create(:geozone)
      visit account_path
      click_link "Verify my account"
      verify_residence
      confirm_phone

      visit admin_stats_path

      expect(page).to have_content "Level two users 1"
    end

  end

  describe "Budget investments" do

    context "Supporting phase" do
      before do
        @budget = create(:budget)
        @group_all_city   = create(:budget_group, budget: @budget)
        @heading_all_city = create(:budget_heading, group: @group_all_city)
      end

      scenario "Number of supports in investment projects" do
        group_2 = create(:budget_group, budget: @budget)
        investment1 = create(:budget_investment, heading: create(:budget_heading, group: group_2))
        investment2 = create(:budget_investment, heading: @heading_all_city)

        1.times { create(:vote, votable: investment1) }
        2.times { create(:vote, votable: investment2) }

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{@budget.id}") do
          click_link "Supporting phase"
        end

        expect(page).to have_content "Votes 3"
      end

      scenario "Number of users that have supported an investment project" do
        user1 = create(:user, :level_two)
        user2 = create(:user, :level_two)
        user3 = create(:user, :level_two)

        group_2 = create(:budget_group, budget: @budget)
        investment1 = create(:budget_investment, heading: create(:budget_heading, group: group_2))
        investment2 = create(:budget_investment, heading: @heading_all_city)

        create(:vote, votable: investment1, voter: user1)
        create(:vote, votable: investment1, voter: user2)
        create(:vote, votable: investment2, voter: user1)

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{@budget.id}") do
          click_link "Supporting phase"
        end

        expect(page).to have_content "Participants 2"
      end

      scenario "Number of users that have supported investments projects per geozone" do
        budget = create(:budget)

        group_all_city  = create(:budget_group, budget: budget)
        group_districts = create(:budget_group, budget: budget)

        all_city    = create(:budget_heading, group: group_all_city)
        carabanchel = create(:budget_heading, group: group_districts)
        barajas     = create(:budget_heading, group: group_districts)

        all_city_investment = create(:budget_investment, heading: all_city)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        Budget::Investment.all.each do |investment|
          create(:vote, votable: investment)
        end

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Supporting phase"
        end

        within("#budget_heading_#{all_city.id}") do
          expect(page).to have_content all_city.name
          expect(page).to have_content 1
        end

        within("#budget_heading_#{carabanchel.id}") do
          expect(page).to have_content carabanchel.name
          expect(page).to have_content 2
        end

        within("#budget_heading_#{barajas.id}") do
          expect(page).to have_content barajas.name
          expect(page).to have_content 0
        end
      end
    end

    context "Balloting phase" do
      before do
        @budget = create(:budget, :balloting)
        @group = create(:budget_group, budget: @budget)
        @heading = create(:budget_heading, group: @group)
        @investment = create(:budget_investment, :feasible, :selected, heading: @heading)
      end

      scenario "Number of votes in investment projects" do
        ballot_1 = create(:budget_ballot, budget: @budget)
        ballot_2 = create(:budget_ballot, budget: @budget)

        group_2 = create(:budget_group, budget: @budget)
        heading_2 = create(:budget_heading, group: group_2)
        investment_2 = create(:budget_investment, :feasible, :selected, heading: heading_2)

        create(:budget_ballot_line, ballot: ballot_1, investment: @investment)
        create(:budget_ballot_line, ballot: ballot_1, investment: investment_2)
        create(:budget_ballot_line, ballot: ballot_2, investment: investment_2)

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{@budget.id}") do
          click_link "Final voting"
        end

        expect(page).to have_content "Votes 3"
      end

      scenario "Number of users that have voted a investment project" do
        user_1 = create(:user, :level_two)
        user_2 = create(:user, :level_two)
        user_3 = create(:user, :level_two)

        ballot_1 = create(:budget_ballot, budget: @budget, user: user_1)
        ballot_2 = create(:budget_ballot, budget: @budget, user: user_2)
        ballot_3 = create(:budget_ballot, budget: @budget, user: user_3)

        create(:budget_ballot_line, ballot: ballot_1, investment: @investment)
        create(:budget_ballot_line, ballot: ballot_2, investment: @investment)

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{@budget.id}") do
          click_link "Final voting"
        end

        expect(page).to have_content "Participants 2"
      end
    end

  end

  context "graphs" do

    scenario "event graphs", :js do
      campaign = create(:campaign)

      visit root_path(track_id: campaign.track_id)
      visit admin_stats_path

      within("#stats") do
        click_link campaign.name
      end

      expect(page).to have_content "#{campaign.name} (1)"
      within("#graph") do
        event_created_at = Ahoy::Event.where(name: campaign.name).first.time
        expect(page).to have_content event_created_at.strftime("%Y-%m-%d")
      end
    end

  end

  context "Proposal notifications" do

    scenario "Summary stats" do
      proposal = create(:proposal)

      create(:proposal_notification, proposal: proposal)
      create(:proposal_notification, proposal: proposal)
      create(:proposal_notification)

      visit admin_stats_path
      click_link "Proposal notifications"

      within("#proposal_notifications_count") do
        expect(page).to have_content "3"
      end

      within("#proposals_with_notifications_count") do
        expect(page).to have_content "2"
      end
    end

    scenario "Index" do
      3.times { create(:proposal_notification) }

      visit admin_stats_path
      click_link "Proposal notifications"

      expect(page).to have_css(".proposal_notification", count: 3)

      ProposalNotification.find_each do |proposal_notification|
        expect(page).to have_content proposal_notification.title
        expect(page).to have_content proposal_notification.body
      end
    end

    scenario "Deleted proposals" do
      proposal_notification = create(:proposal_notification)
      proposal_notification.proposal.destroy

      visit admin_stats_path
      click_link "Proposal notifications"

      expect(page).to have_css(".proposal_notification", count: 1)

      expect(page).to have_content proposal_notification.title
      expect(page).to have_content proposal_notification.body
      expect(page).to have_content "Proposal not available"
    end

  end

  context "Direct messages" do

    scenario "Summary stats" do
      sender = create(:user, :level_two)

      create(:direct_message, sender: sender)
      create(:direct_message, sender: sender)
      create(:direct_message)

      visit admin_stats_path
      click_link "Direct messages"

      within("#direct_messages_count") do
        expect(page).to have_content "3"
      end

      within("#users_who_have_sent_message_count") do
        expect(page).to have_content "2"
      end
    end

  end

  context "Polls" do

    scenario "Total participants by origin" do
      oa = create(:poll_officer_assignment)
      3.times { create(:poll_voter, origin: "web") }

      visit admin_stats_path

      within(".stats") do
        click_link "Polls"
      end

      within("#web_participants") do
        expect(page).to have_content "3"
      end
    end

    scenario "Total participants" do
      user = create(:user, :level_two)
      3.times { create(:poll_voter, user: user) }
      create(:poll_voter)

      visit admin_stats_path

      within(".stats") do
        click_link "Polls"
      end

      within("#participants") do
        expect(page).to have_content "2"
      end
    end

    scenario "Participants by poll" do
      oa = create(:poll_officer_assignment)

      poll1 = create(:poll)
      poll2 = create(:poll)

      1.times { create(:poll_voter, poll: poll1, origin: "web") }
      2.times { create(:poll_voter, poll: poll2, origin: "web") }

      visit admin_stats_path

      within(".stats") do
        click_link "Polls"
      end

      within("#polls") do

        within("#poll_#{poll1.id}") do
          expect(page).to have_content "1"
        end

        within("#poll_#{poll2.id}") do
          expect(page).to have_content "2"
        end

      end
    end

    scenario "Participants by poll question" do
      user1 = create(:user, :level_two)
      user2 = create(:user, :level_two)

      poll = create(:poll)

      question1 = create(:poll_question, :with_answers, poll: poll)
      question2 = create(:poll_question, :with_answers, poll: poll)

      create(:poll_answer, question: question1, author: user1)
      create(:poll_answer, question: question2, author: user1)
      create(:poll_answer, question: question2, author: user2)

      visit admin_stats_path

      within(".stats") do
        click_link "Polls"
      end

      within("#poll_question_#{question1.id}") do
        expect(page).to have_content "1"
      end

      within("#poll_question_#{question2.id}") do
        expect(page).to have_content "2"
      end

      within("#poll_#{poll.id}_questions_total") do
        expect(page).to have_content "2"
      end
    end

  end

end
