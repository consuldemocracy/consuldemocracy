require "rails_helper"

describe "Ballots" do
  let(:user)        { create(:user, :level_two) }
  let!(:budget)     { create(:budget, :balloting) }
  let!(:states)     { create(:budget_group, budget: budget, name: "States") }
  let!(:california) { create(:budget_heading, group: states, name: "California", price: 1000) }
  let!(:new_york)   { create(:budget_heading, group: states, name: "New York", price: 1000000) }

  context "Load" do
    let(:user) do
      create(:user, :level_two, ballot_lines: [create(:budget_investment, :selected, heading: california)])
    end

    before do
      budget.update!(slug: "budget_slug")
      login_as(user)
    end

    scenario "finds ballot using budget slug" do
      visit budget_ballot_path("budget_slug")

      expect(page).to have_content("You have voted one investment")
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_ballot_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_ballot_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "Lines Load" do
    before do
      create(:budget_investment, :selected, heading: california, title: "More rain")
      budget.update!(slug: "budget_slug")
      login_as(user)
    end

    scenario "finds ballot lines using budget slug", :js do
      visit budget_investments_path("budget_slug", states, california)
      add_to_ballot("More rain")

      within("#sidebar") { expect(page).to have_content "More rain" }
    end
  end

  context "Voting" do
    before do
      login_as(user)
      visit budget_path(budget)
    end

    let!(:city) { create(:budget_group, budget: budget, name: "City") }
    let!(:districts) { create(:budget_group, budget: budget, name: "Districts") }

    context "Group and Heading Navigation" do
      scenario "Groups" do
        visit budget_path(budget)

        expect(page).to have_link "City"
        expect(page).to have_link "Districts"
      end

      scenario "Headings" do
        create(:budget_heading, group: city,      name: "Investments Type1")
        create(:budget_heading, group: city,      name: "Investments Type2")
        create(:budget_heading, group: districts, name: "District 1")
        create(:budget_heading, group: districts, name: "District 2")

        visit budget_path(budget)
        click_link "City"

        expect(page).to have_link "Investments Type1"
        expect(page).to have_link "Investments Type2"

        visit budget_path(budget)
        click_link "Districts"

        expect(page).to have_link "District 1"
        expect(page).to have_link "District 2"
      end

      scenario "Investments" do
        create(:budget_heading, group: city, name: "Under the city")

        create(:budget_heading, group: city, name: "Above the city") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Solar panels")
          create(:budget_investment, :selected, heading: heading, title: "Observatory")
        end

        create(:budget_heading, group: districts, name: "District 1") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "New park")
          create(:budget_investment, :selected, heading: heading, title: "Zero-emission zone")
        end

        create(:budget_heading, group: districts, name: "District 2") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Climbing wall")
        end

        visit budget_path(budget)
        click_link "City"
        click_link "Above the city"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "Solar panels"
        expect(page).to have_content "Observatory"

        visit budget_path(budget)

        click_link "Districts"
        click_link "District 1"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "New park"
        expect(page).to have_content "Zero-emission zone"

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 2"

        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content "Climbing wall"
      end

      scenario "Redirect to first heading if there is only one" do
        city_heading    = create(:budget_heading, group: city, name: "City")
        city_investment = create(:budget_investment, :selected, heading: city_heading)

        visit budget_path(budget)
        click_link "City"

        expect(page).to have_content city_investment.title
      end
    end

    context "Adding and Removing Investments" do
      scenario "Add a investment", :js do
        create(:budget_investment, :selected, heading: new_york, price: 10000, title: "Bring back King Kong")
        create(:budget_investment, :selected, heading: new_york, price: 20000, title: "Paint cabs black")

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        add_to_ballot("Bring back King Kong")

        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content "Bring back King Kong"
          expect(page).to have_content "€10,000"
          expect(page).to have_link("Check and confirm my ballot")
        end

        add_to_ballot("Paint cabs black")

        expect(page).to have_css("#amount-spent", text: "€30,000")
        expect(page).to have_css("#amount-available", text: "€970,000")

        within("#sidebar") do
          expect(page).to have_content "Paint cabs black"
          expect(page).to have_content "€20,000"
          expect(page).to have_link("Check and confirm my ballot")
        end
      end

      scenario "Removing a investment", :js do
        investment = create(:budget_investment, :selected, heading: new_york, price: 10000, balloters: [user])

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        expect(page).to have_content investment.title
        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment.title
          expect(page).to have_content "€10,000"
          expect(page).to have_link("Check and confirm my ballot")
        end

        within("#budget_investment_#{investment.id}") do
          find(".remove a").click
        end

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-available", text: "€1,000,000")

        within("#sidebar") do
          expect(page).not_to have_content investment.title
          expect(page).not_to have_content "€10,000"
          expect(page).to have_link("Check and confirm my ballot")
        end
      end

      scenario "the Map shoud be visible before and after", :js do
        create(:budget_investment, :selected, heading: new_york, price: 10000, title: "More bridges")

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        within("#sidebar") do
          expect(page).to have_content "OpenStreetMap"
        end

        add_to_ballot("More bridges")

        within("#sidebar") do
          expect(page).to have_content "More bridges"
          expect(page).to have_content "OpenStreetMap"
        end

        within(".budget-investment", text: "More bridges") do
          click_link "Remove vote"
        end

        within("#sidebar") do
          expect(page).not_to have_content "More bridges"
          expect(page).to have_content "OpenStreetMap"
        end
      end
    end

    #Break up or simplify with helpers
    context "Balloting in multiple headings" do
      scenario "Independent progress bar for headings", :js do
        city_heading      = create(:budget_heading, group: city,      name: "All city",   price: 10000000)
        district_heading1 = create(:budget_heading, group: districts, name: "District 1", price: 1000000)
        district_heading2 = create(:budget_heading, group: districts, name: "District 2", price: 2000000)

        create(:budget_investment, :selected, heading: city_heading,      price: 10000, title: "Cheap")
        create(:budget_investment, :selected, heading: district_heading1, price: 20000, title: "Average")
        create(:budget_investment, :selected, heading: district_heading2, price: 30000, title: "Expensive")

        visit budget_path(budget)
        click_link "City"

        add_to_ballot("Cheap")

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content "Cheap"
          expect(page).to have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 1"

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-spent", text: "€1,000,000")

        add_to_ballot("Average")

        expect(page).to have_css("#amount-spent",     text: "€20,000")
        expect(page).to have_css("#amount-available", text: "€980,000")

        within("#sidebar") do
          expect(page).to have_content "Average"
          expect(page).to have_content "€20,000"

          expect(page).not_to have_content "Cheap"
          expect(page).not_to have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "City"

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content "Cheap"
          expect(page).to have_content "€10,000"

          expect(page).not_to have_content "Average"
          expect(page).not_to have_content "€20,000"
        end

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 2"

        expect(page).to have_content("You have active votes in another heading: District 1")
      end
    end

    scenario "Display progress bar after first vote", :js do
      create(:budget_investment, :selected, heading: new_york, price: 10000, title: "Park expansion")

      visit budget_investments_path(budget, heading_id: new_york.id)

      add_to_ballot("Park expansion")

      within("#progress_bar") do
        expect(page).to have_css("#amount-spent", text: "€10,000")
      end
    end
  end

  context "Groups" do
    before { login_as(user) }

    scenario "Select my heading", :js do
      create(:budget_investment, :selected, heading: california, title: "Green beach")

      visit budget_path(budget)
      click_link "States"
      click_link "California"

      add_to_ballot("Green beach")

      visit budget_path(budget)
      click_link "States"

      expect(page).to have_content "California"
      expect(page).to have_css("#budget_heading_#{california.id}.is-active")
    end

    scenario "Change my heading", :js do
      create(:budget_investment, :selected, heading: california, title: "Early ShakeAlert", balloters: [user])
      create(:budget_investment, :selected, heading: new_york, title: "Avengers Tower")

      visit budget_investments_path(budget, heading_id: california.id)

      within(".budget-investment", text: "Early ShakeAlert") do
        find(".remove a").click
        expect(page).to have_link "Vote"
      end

      visit budget_investments_path(budget, heading_id: new_york.id)

      add_to_ballot("Avengers Tower")

      visit budget_path(budget)
      click_link "States"
      expect(page).to have_css("#budget_heading_#{new_york.id}.is-active")
      expect(page).not_to have_css("#budget_heading_#{california.id}.is-active")
    end

    scenario "View another heading" do
      create(:budget_investment, :selected, heading: california, balloters: [user])

      visit budget_investments_path(budget, heading_id: new_york.id)

      expect(page).not_to have_css "#progressbar"
      expect(page).to have_content "You have active votes in another heading: California"
      expect(page).to have_link california.name, href: budget_investments_path(budget, heading_id: california.id)
    end
  end

  context "Showing the ballot" do
    scenario "Do not display heading name if there is only one heading in the group (example: group city)" do
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      visit budget_path(budget)
      click_link group.name
      # No need to click on the heading name
      expect(page).to have_content("Investment projects with scope: #{heading.name}")
      expect(page).to have_current_path(budget_investments_path(budget), ignore_query: true)
    end

    scenario "Displaying the correct group, heading, count & amount" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      create(:budget_heading, name: "District A", group: group1, price: 100)
      heading1 = create(:budget_heading, name: "District 1", group: group1, price: 100)
      heading2 = create(:budget_heading, name: "District 2", group: group2, price: 50)
      create(:budget_heading, name: "District Z", group: group1, price: 100)

      investment1 = create(:budget_investment, :selected, price: 10, heading: heading1)
      investment2 = create(:budget_investment, :selected, price: 10, heading: heading1)
      investment3 = create(:budget_investment, :selected, price: 5,  heading: heading2)
      investment4 = create(:budget_investment, :selected, price: 5,  heading: heading2)
      investment5 = create(:budget_investment, :selected, price: 5,  heading: heading2)

      user = create(:user, :level_two,
                    ballot_lines: [investment1, investment2, investment3, investment4, investment5])

      login_as(user)
      visit budget_ballot_path(budget)

      expect(page).to have_content("You have voted 5 investments")

      within("#budget_group_#{group1.id}") do
        expect(page).to have_content "#{group1.name} - #{heading1.name}"
        expect(page).to have_content "Amount spent €20"
        expect(page).to have_link "You still have €80 to invest.", href: budget_group_path(budget, group1)
      end

      within("#budget_group_#{group2.id}") do
        expect(page).to have_content "#{group2.name} - #{heading2.name}"
        expect(page).to have_content "Amount spent €15"
        expect(page).to have_content "You still have €35 to invest"
      end
    end

    scenario "Display links to vote on groups with no investments voted yet" do
      group = create(:budget_group, budget: budget)

      login_as(user)
      visit budget_ballot_path(budget)

      expect(page).to have_link "You have not voted on this group yet, go vote!", href: budget_group_path(budget, group)
    end
  end

  scenario "Removing investments from ballot", :js do
    investment = create(:budget_investment, :selected, price: 10, heading: new_york)
    user = create(:user, :level_two, ballot_lines: [investment])

    login_as(user)
    visit budget_ballot_path(budget)

    expect(page).to have_content("You have voted one investment")

    within("#budget_investment_#{investment.id}") do
      find(".icon-x").click
    end

    expect(page).to have_current_path(budget_ballot_path(budget))
    expect(page).to have_content("You have voted 0 investments")
  end

  scenario "Removing investments from ballot (sidebar)", :js do
    investment1 = create(:budget_investment, :selected, price: 10000, heading: new_york)
    investment2 = create(:budget_investment, :selected, price: 20000, heading: new_york)
    user = create(:user, :level_two, ballot_lines: [investment1, investment2])

    login_as(user)
    visit budget_investments_path(budget, heading_id: new_york.id)

    expect(page).to have_css("#amount-spent", text: "€30,000")
    expect(page).to have_css("#amount-available", text: "€970,000")

    within("#sidebar") do
      expect(page).to have_content investment1.title
      expect(page).to have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end

    within("#sidebar #budget_investment_#{investment1.id}_sidebar") do
      find(".icon-x").click
    end

    expect(page).to have_css("#amount-spent", text: "€20,000")
    expect(page).to have_css("#amount-available", text: "€980,000")

    within("#sidebar") do
      expect(page).not_to have_content investment1.title
      expect(page).not_to have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end
  end

  scenario "Back link after removing an investment from Ballot", :js do
    create(:budget_investment, :selected, heading: new_york, price: 10, title: "Sully monument")

    login_as(user)
    visit budget_investments_path(budget, heading_id: new_york.id)
    add_to_ballot("Sully monument")

    within(".budget-heading") do
      click_link "Check and confirm my ballot"
    end

    expect(page).to have_content("You have voted one investment")

    within(".ballot-list li", text: "Sully monument") do
      find(".icon-x").click
    end

    expect(page).to have_content("You have voted 0 investments")

    click_link "Go back"

    expect(page).to have_current_path(budget_investments_path(budget, heading_id: new_york.id))
  end

  context "Permissions" do
    scenario "User not logged in", :js do
      investment = create(:budget_investment, :selected, heading: new_york)

      visit budget_investments_path(budget, heading_id: new_york.id)

      within("#budget_investment_#{investment.id}") do
        hover_over_ballot

        expect(page).to have_content "You must sign in or sign up to continue."
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "User not verified", :js do
      unverified_user = create(:user)
      investment = create(:budget_investment, :selected, heading: new_york)

      login_as(unverified_user)
      visit budget_investments_path(budget, heading_id: new_york.id)

      within("#budget_investment_#{investment.id}") do
        hover_over_ballot

        expect(page).to have_content "Only verified users can vote on investments"
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "User is organization", :js do
      org = create(:organization)
      investment = create(:budget_investment, :selected, heading: new_york)

      login_as(org.user)
      visit budget_investments_path(budget, heading_id: new_york.id)

      within("#budget_investment_#{investment.id}") do
        hover_over_ballot

        expect_message_organizations_cannot_vote
      end
    end

    scenario "Unselected investments" do
      investment = create(:budget_investment, heading: new_york, title: "WTF asdfasfd")

      login_as(user)
      visit budget_path(budget)
      click_link states.name
      click_link new_york.name

      expect(page).not_to have_css("#budget_investment_#{investment.id}")
    end

    scenario "Investments with feasibility undecided are not shown" do
      investment = create(:budget_investment, :undecided, heading: new_york)

      login_as(user)
      visit budget_path(budget)
      click_link states.name
      click_link new_york.name

      within("#budget-investments") do
        expect(page).not_to have_css("div.ballot")
        expect(page).not_to have_css("#budget_investment_#{investment.id}")
      end
    end

    scenario "Different district", :js do
      bi1 = create(:budget_investment, :selected, heading: california)
      bi2 = create(:budget_investment, :selected, heading: new_york)
      user = create(:user, :level_two, ballot_lines: [bi1])

      login_as(user)
      visit budget_investments_path(budget, heading: new_york)

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).to have_content("already voted a different heading")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "Insufficient funds (on page load)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)
      user = create(:user, :level_two, ballot_lines: [bi1])

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "Insufficient funds (added after create)", :js do
      create(:budget_investment, :selected, heading: california, price: 600, title: "Build replicants")
      create(:budget_investment, :selected, heading: california, price: 500, title: "Build terminators")

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within(".budget-investment", text: "Build replicants") do
        hover_over_ballot

        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: false)
      end

      add_to_ballot("Build replicants")

      within(".budget-investment", text: "Build terminators") do
        hover_over_ballot

        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "Insufficient funds (removed after destroy)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)
      user = create(:user, :level_two, ballot_lines: [bi1])

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end

      within("#budget_investment_#{bi1.id}") do
        find(".remove a").click
        expect(page).to have_css ".add a"
      end

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: false)
      end
    end

    scenario "Insufficient funds (removed after destroying from sidebar)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)
      user = create(:user, :level_two, ballot_lines: [bi1])

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end

      within("#budget_investment_#{bi1.id}_sidebar") do
        find(".icon-x").click
      end

      expect(page).not_to have_css "#budget_investment_#{bi1.id}_sidebar"

      within("#budget_investment_#{bi2.id}") do
        hover_over_ballot

        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", obscured: false)
      end
    end

    scenario "Edge case voting a non-elegible investment", :js do
      investment1 = create(:budget_investment, :selected, heading: new_york, price: 10000)

      login_as(user)
      visit budget_path(budget)
      click_link "States"
      click_link "New York"

      new_york.update!(price: 10)

      within("#budget_investment_#{investment1.id}") do
        find(".in-favor a").click

        expect(page).not_to have_content "Remove"
        expect(page).not_to have_selector(".participation-not-allowed")

        hover_over_ballot

        expect(page).to have_selector(".participation-not-allowed")
        expect(page).to have_selector(".in-favor a", obscured: true)
      end
    end

    scenario "Balloting is disabled when budget isn't in the balotting phase", :js do
      budget.update!(phase: "accepting")

      bi1 = create(:budget_investment, :selected, heading: california, price: 600)

      login_as(user)

      visit budget_investments_path(budget, heading_id: california.id)
      within("#budget_investment_#{bi1.id}") do
        expect(page).not_to have_css("div.ballot")
      end
    end
  end
end
