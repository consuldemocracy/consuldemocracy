require 'rails_helper'

feature 'Stats' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
    visit root_path
  end

  context 'Summary' do

    scenario 'General' do
      create(:debate)
      2.times { create(:proposal) }
      3.times { create(:comment, commentable: Debate.first) }
      4.times { create(:visit) }
      6.times { create(:spending_proposal) }

      visit admin_stats_path

      expect(page).to have_content "Debates 1"
      expect(page).to have_content "Proposals 2"
      expect(page).to have_content "Comments 3"
      expect(page).to have_content "Visits 4"
      expect(page).to have_content "Investment projects 6"
    end

    scenario 'Votes' do
      debate = create(:debate)
      create(:vote, votable: debate)

      proposal = create(:proposal)
      2.times { create(:vote, votable: proposal) }

      comment = create(:comment)
      3.times { create(:vote, votable: comment) }

      spending_proposal = create(:spending_proposal)
      5.times { create(:vote, votable: spending_proposal) }

      visit admin_stats_path

      expect(page).to have_content "Debate votes 1"
      expect(page).to have_content "Proposal votes 2"
      expect(page).to have_content "Comment votes 3"
      expect(page).to have_content "Investment project votes 5"
      expect(page).to have_content "Total votes 11"
    end

  end

  context "Users" do

    scenario 'Summary' do
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

  end

  context "Spending Proposals" do

    scenario "Number of users that have voted a investment project" do
      spending_proposal = create(:spending_proposal, :feasible)

      ballot_with_votes = create(:ballot, spending_proposals: [spending_proposal])
      ballot_with_votes2 = create(:ballot, spending_proposals: [spending_proposal])
      ballot_without_votes = create(:ballot)

      visit admin_stats_path
      expect(page).to have_content "Budgets voted 2"
    end

    scenario "Number of users that have voted a investment project per geozone" do
      california = create(:geozone)

      create(:spending_proposal, :feasible, geozone: california)
      create(:spending_proposal, :feasible, geozone: california)
      create(:spending_proposal, :feasible, geozone: nil)

      SpendingProposal.find_each do |spending_proposal|
        create(:ballot, spending_proposals: [spending_proposal], geozone: spending_proposal.geozone)
      end

      visit admin_stats_path
      click_link "Participatory Budget 2016"

      within("#geozone_#{california.id}") do
        expect(page).to have_content california.name
        expect(page).to have_content 2
      end
    end

    scenario "Number of users that have voted geozone/no-geozone wide proposals" do
      with_geozone = create(:spending_proposal, :feasible, geozone: create(:geozone))
      no_geozone   = create(:spending_proposal, :feasible, geozone: nil)

      both        = create(:ballot, spending_proposals: [with_geozone, no_geozone], geozone: with_geozone.geozone)
      geozoned    = create(:ballot, spending_proposals: [with_geozone], geozone: with_geozone.geozone)
      no_geozoned = create(:ballot, spending_proposals: [no_geozone], geozone: nil)


      visit admin_stats_path
      click_link "Participatory Budget 2016"

      within("#city_voters") {expect(page).to have_content 2}
      within("#district_voters") {expect(page).to have_content 2}
      within("#in_both_voters") {expect(page).to have_content 1}
      within("#only_district_voters") {expect(page).to have_content 1}
      within("#only_city_voters") {expect(page).to have_content 1}
    end

    scenario "Number of votes in investment projects" do
      3.times { create(:ballot_line) }
      visit admin_stats_path
      expect(page).to have_content "Votes in investment projects 3"
    end
  end

  feature "Budget investments" do
    context "Supporting phase" do
      let!(:budget) { create(:budget) }
      # TODO change name to city_heading?
      let!(:city_group) { create(:budget_group, budget: budget) }
      let!(:city_heading) { create(:budget_heading, :city_heading, group: city_group) }

      scenario "Number of supports in investment projects" do
        group_2 = create(:budget_group, budget: budget)
        investment1 = create(:budget_investment, heading: create(:budget_heading, group: group_2))
        investment2 = create(:budget_investment, heading: city_heading)

        1.times { create(:vote, votable: investment1) }
        2.times { create(:vote, votable: investment2) }

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Supporting phase"
        end

        expect(page).to have_content "Votes 3"
      end

      scenario "Number of users that have supported an investment project" do
        user1 = create(:user, :level_two)
        user2 = create(:user, :level_two)
        user3 = create(:user, :level_two)

        group_2 = create(:budget_group, budget: budget)
        investment1 = create(:budget_investment, heading: create(:budget_heading, group: group_2))
        investment2 = create(:budget_investment, heading: city_heading)

        create(:vote, votable: investment1, voter: user1)
        create(:vote, votable: investment1, voter: user2)
        create(:vote, votable: investment2, voter: user1)

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Supporting phase"
        end

        expect(page).to have_content "Participants 2"
      end

      scenario "Number of users that have supported investments projects per geozone" do
        group_districts = create(:budget_group, budget: budget)

        all_city    = city_heading
        carabanchel = create(:budget_heading, group: group_districts)
        barajas     = create(:budget_heading, group: group_districts)

        all_city_investment = create(:budget_investment, heading: all_city)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        Budget::Investment.find_each do |investment|
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

      scenario "Number of users that have supported geozone/no-geozone wide proposals" do
        group_districts = create(:budget_group, budget: budget)

        carabanchel = create(:budget_heading, group: group_districts)
        all_city_investment = create(:budget_investment, heading: city_heading)
        district_investment = create(:budget_investment, heading: carabanchel)

        user_both = create(:user, :level_two)
        user_city = create(:user, :level_two)
        user_district = create(:user, :level_two)

        create(:vote, voter: user_both, votable: all_city_investment)
        create(:vote, voter: user_both, votable: district_investment)

        create(:vote, voter: user_city, votable: all_city_investment)
        create(:vote, voter: user_district, votable: district_investment)

        visit admin_stats_path
        click_link "Participatory Budgets"
        within("#budget_#{budget.id}") do
          click_link "Supporting phase"
        end

        within("#city_voters") {expect(page).to have_content 2}
        within("#district_voters") {expect(page).to have_content 2}
        within("#in_both_voters") {expect(page).to have_content 1}
        within("#only_district_voters") {expect(page).to have_content 1}
        within("#only_city_voters") {expect(page).to have_content 1}
      end
    end

    context "Balloting phase" do
      background do
        @budget = create(:budget, :balloting)
        @group = create(:budget_group, budget: @budget)
        @heading = create(:budget_heading, group: @group)
        @investment = create(:budget_investment, :feasible, :selected, heading: @heading)

        allow_any_instance_of(Admin::StatsController).
        to receive(:city_heading).and_return(@heading)
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

        expect { Rake::Task['budgets:stats:balloting'].execute }.not_to raise_exception

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

        expect { Rake::Task['budgets:stats:balloting'].execute }.not_to raise_exception

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

    context "custom graphs" do

      scenario "spending proposals", :js do
        spending_proposal = create(:spending_proposal)

        visit admin_stats_path

        within("#stats") do
          click_link "Investment projects"
        end

        expect(page).to have_content "Investment projects (1)"
        within("#graph") do
          expect(page).to have_content spending_proposal.created_at.strftime("%Y-%m-%d")
        end
      end

      scenario "Unverified users", :js do
        user = create(:user)

        visit admin_stats_path

        within("#stats") do
          click_link "Unverified users"
        end

        expect(page).to have_content "Unverified users (2)" #including seed admin
        within("#graph") do
          expect(page).to have_content user.created_at.strftime("%Y-%m-%d")
        end
      end

    end

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

  context "Redeemable codes" do

    scenario "Total" do
      create(:user, redeemable_code: 'abc')
      create(:user, redeemable_code: 'def')
      create(:user, redeemable_code: 'ghi')

      visit admin_stats_path
      click_link "Redeemable codes"

      within("#redeemable_codes_count") do
        expect(page).to have_content "3"
      end
    end

    scenario "After campaign of June 17th 2016" do
      create(:user, redeemable_code: 'abd', verified_at: Date.new(2016, 6, 16))
      create(:user, redeemable_code: 'def', verified_at: Date.new(2016, 6, 17))
      create(:user, redeemable_code: 'ghi', verified_at: Date.new(2016, 6, 18))

      visit admin_stats_path
      click_link "Redeemable codes"

      within("#redeemable_codes_after_campaign_count") do
        expect(page).to have_content "2"
      end
    end

  end

  context "User invites" do

    background do
      create(:campaign, track_id: 172943750183759812)
    end

    scenario "Invitations sent" do
      login_as_manager
      visit new_management_user_invite_path

      fill_in "emails", with: "john@example.com, ana@example.com, isable@example.com"
      click_button "Send invitations"

      expect(page).to have_content "3 invitations have been sent."

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_stats_path
      click_link "Invitations"

      within("#total") do
        expect(page).to have_content "3"
      end
    end

    scenario "Clicks on registration button" do
      login_as_manager
      send_user_invite
      logout(:user)

      email = open_last_email
      visit_in_email "Complete registration"

      expect(current_url).to include(new_user_registration_path)
      click_button "Register"

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_stats_path
      click_link "Invitations"

      within("#clicked_email_link") do
        expect(page).to have_content "1"
      end

      within("#clicked_signup_button") do
        expect(page).to have_content "1"
      end
    end

    scenario "Does not click on registration button" do
      login_as_manager
      send_user_invite
      logout(:user)

      email = open_last_email
      visit_in_email "Complete registration"

      expect(current_url).to include(new_user_registration_path)

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_stats_path
      click_link "Invitations"

      within("#clicked_email_link") do
        expect(page).to have_content "1"
      end

      within("#clicked_signup_button") do
        expect(page).to have_content "0"
      end
    end

  end

  context "Probes" do

    scenario "Index" do
      probe1 = Probe.create(codename: 'town_planning')
      probe2 = Probe.create(codename: 'plaza')

      visit admin_probes_path

      expect(page).to have_link "Town planning - Benches", href: admin_probe_path(probe1)
      expect(page).to have_link "Remodeling of the Plaza España", href: admin_probe_path(probe2)
    end

    scenario "Show" do
      probe = Probe.create(codename: 'plaza')

      visit admin_probe_path(probe)

      expect(page).to have_content "Option"
      expect(page).to have_content "Votes"
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
