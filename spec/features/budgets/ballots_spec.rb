require 'rails_helper'

feature 'Ballots' do

  let(:budget)  { create(:budget, phase: "balloting") }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, name: "Heading 1", price: 1000000) }

  context "Voting" do
    let!(:user) { create(:user, :level_two) }

    background do
      login_as(user)
      visit budget_path(budget)
    end

    context "City" do

      scenario "Add a proposal", :js do
        investment1 = create(:budget_investment, :feasible, :finished, budget: budget, heading: heading, price: 10000)
        investment2 = create(:budget_investment, :feasible, :finished, budget: budget, heading: heading, price: 20000)

        visit budget_path(budget)
        click_link "Heading 1"

        within("#budget_investment_#{investment1.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"
        end

        within("#budget_investment_#{investment2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "€30,000")
        expect(page).to have_css("#amount-available", text: "€970,000")

        within("#sidebar") do
          expect(page).to have_content investment2.title
          expect(page).to have_content "€20,000"
        end
      end

      scenario "Remove a proposal", :js do
        investment1 = create(:budget_investment, :feasible, :finished, budget: budget, heading: heading, price: 10000)
        ballot = create(:budget_ballot, user: user, budget: budget, investments: [investment1])

        visit budget_path(budget)
        click_link "Heading 1"

        expect(page).to have_content investment1.title
        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"
        end

        within("#budget_investment_#{investment1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-available", text: "€1,000,000")

        within("#sidebar") do
          expect(page).to_not have_content investment1.title
          expect(page).to_not have_content "€10,000"
        end
      end

    end

    #Not used anymore?
    xcontext 'District' do

      scenario "Add a proposal", :js do
        carabanchel = create(:geozone, name: "Carabanchel")

        sp1 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 10000)
        sp2 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 20000)

        click_link "Vote district proposals"
        click_link carabanchel.name

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
          expect(page).to have_content "Remove"
        end

        visit spending_proposals_path(geozone: carabanchel)

        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€3,237,830")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "€10,000"
        end

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "€30,000")
        expect(page).to have_css("#amount-available", text: "€3,217,830")

        within("#sidebar") do
          expect(page).to have_content sp2.title
          expect(page).to have_content "€20,000"
        end
      end

      scenario "Remove a proposal", :js do
        carabanchel = create(:geozone, name: "Carabanchel")

        sp1 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 10000)
        ballot = create(:ballot, user: user, geozone: carabanchel, spending_proposals: [sp1])

        click_link "Vote district proposals"
        click_link carabanchel.name

        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€3,237,830")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "€10,000"
        end

        within("#spending_proposal_#{sp1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-available", text: "€3,247,830")

        within("#sidebar") do
          expect(page).to_not have_content sp1.title
          expect(page).to_not have_content "€10,000"
        end
      end

    end

    #Break up or simplify with helpers
    context "Balloting in multiple headings" do

      scenario "Independent progress bar for headings", :js do
        city      = create(:budget_group, budget: budget)
        districts = create(:budget_group, budget: budget)

        city_heading      = create(:budget_heading, group: city,      name: "All city",   price: 10000000)
        district_heading1 = create(:budget_heading, group: districts, name: "District 1", price: 1000000)
        district_heading2 = create(:budget_heading, group: districts, name: "District 2", price: 2000000)

        investment1 = create(:budget_investment, :feasible, :finished, heading: city_heading,      price: 10000)
        investment2 = create(:budget_investment, :feasible, :finished, heading: district_heading1, price: 20000)
        investment3 = create(:budget_investment, :feasible, :finished, heading: district_heading2, price: 30000)

        visit budget_path(budget)
        click_link "All city"

        within("#budget_investment_#{investment1.id}") do
          find('.add a').trigger('click')
          expect(page).to have_content "Remove"
        end

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "District 1"

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-spent", text: "€1,000,000")

        within("#budget_investment_#{investment2.id}") do
          find('.add a').trigger('click')
          expect(page).to have_content "Remove"
        end

        visit budget_path(budget)
        click_link "District 1"

        expect(page).to have_css("#amount-spent",     text: "€20,000")
        expect(page).to have_css("#amount-available", text: "€980,000")

        within("#sidebar") do
          expect(page).to have_content investment2.title
          expect(page).to have_content "€20,000"

          expect(page).to_not have_content investment1.title
          expect(page).to_not have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "All city"

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"

          expect(page).to_not have_content investment2.title
          expect(page).to_not have_content "€20,000"
        end

        visit budget_path(budget)
        click_link "District 2"

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-spent", text: "€2,000,000")
      end
    end

    scenario "Display progress bar after first vote", :js do
      investment = create(:budget_investment, :feasible, :finished, heading: heading, price: 10000)

      visit budget_path(budget)
      click_link "Heading 1"

      expect(page).to have_content investment.title
      within("#budget_investment_#{investment.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove"
      end

      within("#progress_bar") do
        expect(page).to have_css("#amount-spent", text: "€10,000")
      end
    end
  end

  context "Groups" do
    let!(:user) { create(:user, :level_two) }
    let!(:districts_group)    { create(:budget_group, budget: budget, name: "Districts") }
    let!(:california_heading) { create(:budget_heading, group: districts_group, name: "California") }
    let!(:new_york_heading)   { create(:budget_heading, group: districts_group, name: "New York") }
    let!(:investment)         { create(:budget_investment, :feasible, :finished, heading: california_heading) }

    background do
      login_as(user)
    end

    scenario 'Select my heading', :js do
      visit budget_path(budget)
      click_link "Districts"
      click_link "California"

      within("#budget_investment_#{investment.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove"
      end

      visit budget_path(budget)
      click_link "Districts"

      expect(page).to have_content "California"
      expect(page).to have_css("#budget_heading_#{california_heading.id}.active")
    end

    scenario 'Change my heading', :js do
      investment1 = create(:budget_investment, :feasible, :finished, heading: california_heading)
      investment2 = create(:budget_investment, :feasible, :finished, heading: new_york_heading)

      create(:budget_ballot, user: user, budget: budget, investments: [investment1])

      visit budget_investments_path(budget, heading_id: california_heading.id)

      within("#budget_investment_#{investment1.id}") do
        find('.remove a').trigger('click')
      end

      visit budget_investments_path(budget, heading_id: new_york_heading.id)

      within("#budget_investment_#{investment2.id}") do
        find('.add a').trigger('click')
      end

      visit budget_path(budget)
      click_link "Districts"
      expect(page).to have_css("#budget_heading_#{new_york_heading.id}.active")
      expect(page).to_not have_css("#budget_heading_#{california_heading.id}.active")
    end

    scenario 'View another heading' do
      investment = create(:budget_investment, :feasible, :finished, heading: california_heading)

      create(:budget_ballot, user: user, budget: budget, investments: [investment])

      visit budget_investments_path(budget, heading_id: new_york_heading.id)

      expect(page).to_not have_css "#progressbar"
      expect(page).to have_content "You have active votes in another district:"
      expect(page).to have_link california_heading.name, href: budget_investments_path(budget, heading: california_heading)
    end

  end

  context 'Showing the ballot' do
    pending "Do not display heading name if there is only one heading in the group (example: group city)"

    scenario 'Displaying the correct count & amount' do
      user = create(:user, :level_two)

      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, name: "District 1", group: group1, price: 100)
      heading2 = create(:budget_heading, name: "District 2", group: group2, price: 50)

      ballot = create(:budget_ballot, user: user, budget: budget)

      investment1 = create(:budget_investment, :feasible, price: 10, heading: heading1, group: group1)
      investment2 = create(:budget_investment, :feasible, price: 10, heading: heading1, group: group1)

      investment3 = create(:budget_investment, :feasible, price: 5,  heading: heading2, group: group2)
      investment4 = create(:budget_investment, :feasible, price: 5,  heading: heading2, group: group2)
      investment5 = create(:budget_investment, :feasible, price: 5,  heading: heading2, group: group2)

      create(:budget_ballot_line, ballot: ballot, investment: investment1, group: group1)
      create(:budget_ballot_line, ballot: ballot, investment: investment2, group: group1)

      create(:budget_ballot_line, ballot: ballot, investment: investment3, group: group2)
      create(:budget_ballot_line, ballot: ballot, investment: investment4, group: group2)
      create(:budget_ballot_line, ballot: ballot, investment: investment5, group: group2)

      login_as(user)
      visit budget_ballot_path(budget)

      expect(page).to have_content("You have voted 5 proposals")

      within("#budget_group_#{group1.id}") do
        expect(page).to have_content "#{group1.name} - #{heading1.name}"
        expect(page).to have_content "Amount spent €20"
        expect(page).to have_content "You still have €80 to invest"
      end

      within("#budget_group_#{group2.id}") do
        expect(page).to have_content "#{group2.name} - #{heading2.name}"
        expect(page).to have_content "Amount spent €15"
        expect(page).to have_content "You still have €35 to invest"
      end
    end

  end

  scenario 'Removing spending proposals from ballot', :js do
    user = create(:user, :level_two)
    ballot = create(:budget_ballot, user: user, budget: budget)
    investment = create(:budget_investment, :feasible, :finished, price: 10, heading: heading, group: group)
    create(:budget_ballot_line, ballot: ballot, investment: investment, heading: heading, group: group)

    login_as(user)
    visit budget_ballot_path(budget)

    expect(page).to have_content("You have voted one proposal")

    within("#budget_investment_#{investment.id}") do
      find(".remove-investment-project").trigger('click')
    end

    expect(current_path).to eq(budget_ballot_path(budget))
    expect(page).to have_content("You have voted 0 proposals")
  end

  scenario 'Removing spending proposals from ballot (sidebar)', :js do
    user = create(:user, :level_two)
    investment1 = create(:budget_investment, :feasible, :finished, price: 10000, heading: heading)
    investment2 = create(:budget_investment, :feasible, :finished, price: 20000, heading: heading)

    ballot = create(:budget_ballot, budget: budget, user: user, investments: [investment1, investment2])

    login_as(user)
    visit budget_investments_path(budget, heading_id: heading.id)

    expect(page).to have_css("#amount-spent", text: "€30,000")
    expect(page).to have_css("#amount-available", text: "€970,000")

    within("#sidebar") do
      expect(page).to have_content investment1.title
      expect(page).to have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end

    within("#sidebar #budget_investment_#{investment1.id}_sidebar") do
      find(".remove-investment-project").trigger('click')
    end

    expect(page).to have_css("#amount-spent", text: "€20,000")
    expect(page).to have_css("#amount-available", text: "€980,000")

    within("#sidebar") do
      expect(page).to_not have_content investment1.title
      expect(page).to_not have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end
  end

  context 'Permissions' do

    scenario 'User not logged in', :js do
      investment = create(:budget_investment, :feasible, :finished, heading: heading)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        find("div.ballot").hover
        expect_message_you_need_to_sign_in_to_ballot
      end
    end

    scenario 'User not verified', :js do
      user = create(:user)
      investment = create(:budget_investment, :feasible, :finished, heading: heading)

      login_as(user)
      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        find("div.ballot").hover
        expect_message_only_verified_can_vote_investments
      end
    end

    scenario 'User is organization', :js do
      org = create(:organization)
      investment = create(:budget_investment, :feasible, :finished, heading: heading)

      login_as(org.user)
      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        find("div.ballot").hover
        expect_message_organizations_cannot_vote
      end
    end

    scenario 'Unfeasible investments' do
      user = create(:user, :level_two)
      investment = create(:budget_investment, :finished, :unfeasible, heading: heading)

      login_as(user)
      visit budget_investments_path(budget, heading_id: heading.id, unfeasible: 1)

      within("#budget_investment_#{investment.id}") do
        expect(page).to_not have_css("div.ballot")
      end
    end

    scenario 'Investments with feasibility undecided are not shown' do
      user = create(:user, :level_two)
      investment = create(:budget_investment, :finished, feasibility: "undecided", heading: heading)

      login_as(user)
      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget-investments") do
        expect(page).to_not have_css("div.ballot")
        expect(page).to_not have_css("#budget_investment_#{investment.id}")
      end
    end

    scenario 'Different district', :js do
      user = create(:user, :level_two)
      california = create(:geozone)
      new_york = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, geozone: california)
      sp2 = create(:spending_proposal, :feasible, :finished, geozone: new_york)

      create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

      login_as(user)
      visit spending_proposals_path(geozone: new_york)

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect_message_already_voted_in_another_geozone(california)
      end
    end

    scenario 'Insufficient funds', :js do
      user = create(:user, :level_two)
      california = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, price: 25000000)

      login_as(user)
      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp1.id}") do
        find('.add a').trigger('click')
        expect_message_insufficient_funds
      end
    end

    scenario 'Displays error message for all proposals (on create)', :js do
      user = create(:user, :level_two)
      california = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, price: 20000000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 5000000)

      login_as(user)
      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp1.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove vote"
      end

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect_message_insufficient_funds
      end

    end

    scenario 'Displays error message for all proposals (on destroy)', :js do
      user = create(:user, :level_two)

      sp1 = create(:spending_proposal, :feasible, :finished, price: 24000000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 5000000)

      create(:ballot, user: user, spending_proposals: [sp1])

      login_as(user)
      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect(page).to have_content "This proposal's price is more than the available amount left"
        expect(page).to have_selector('.in-favor a', visible: false)
      end

      within("#spending_proposal_#{sp1.id}") do
        find('.remove a').trigger('click')
      end

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect(page).to_not have_content "This proposal's price is more than the available amount left"
        expect(page).to have_selector('.in-favor a', visible: true)
      end
    end

    scenario 'Displays error message for all proposals (on destroy from sidebar)', :js do
      user = create(:user, :level_two)

      sp1 = create(:spending_proposal, :feasible, :finished, price: 24000000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 5000000)

      create(:ballot, user: user, spending_proposals: [sp1])

      login_as(user)
      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect(page).to have_content "This proposal's price is more than the available amount left"
        expect(page).to have_selector('.in-favor a', visible: false)
      end

      within("#spending_proposal_#{sp1.id}_sidebar") do
        find('.remove-investment-project').trigger('click')
      end

      expect(page).to_not have_css "#spending_proposal_#{sp1.id}_sidebar"

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect(page).to_not have_content "This proposal's price is more than the available amount left"
        expect(page).to have_selector('.in-favor a', visible: true)
      end
    end

    scenario "Display hover for ajax generated content", :js do
      user = create(:user, :level_two)
      california = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, price: 20000000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 5000000)

      login_as(user)
      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp1.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove vote"
      end

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").trigger(:mouseover)
        expect_message_insufficient_funds
      end
    end


  end

feature "Ballots in the wrong phase" do

  background { login_as(create(:user, :level_two)) }
  let(:sp) { create(:spending_proposal, :feasible, :finished, price: 10000) }

  scenario "When not on phase 3" do
    Setting['feature.spending_proposal_features.phase3'] = nil
    visit create_ballot_line_path(spending_proposal_id: sp.id)
    expect(page.status_code).to eq(403)
  end

  scenario "When in phase 3 but voting disabled" do
    Setting['feature.spending_proposal_features.phase3'] = true
    Setting['feature.spending_proposal_features.final_voting_allowed'] = nil
    expect{visit create_ballot_line_path(spending_proposal_id: sp.id)}.to raise_error(ActionController::RoutingError)
  end
end

