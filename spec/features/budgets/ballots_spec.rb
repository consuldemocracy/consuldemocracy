require "rails_helper"

feature "Ballots" do

  let!(:user)       { create(:user, :level_two) }
  let!(:budget)     { create(:budget, phase: "balloting") }
  let!(:states)     { create(:budget_group, budget: budget, name: "States") }
  let!(:california) { create(:budget_heading, group: states, name: "California", price: 1000) }
  let!(:new_york)   { create(:budget_heading, group: states, name: "New York", price: 1000000) }

  context "Voting" do

    background do
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
        city_heading1     = create(:budget_heading, group: city,      name: "Investments Type1")
        city_heading2     = create(:budget_heading, group: city,      name: "Investments Type2")
        district_heading1 = create(:budget_heading, group: districts, name: "District 1")
        district_heading2 = create(:budget_heading, group: districts, name: "District 2")

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
        city_heading1     = create(:budget_heading, group: city,      name: "Investments Type1")
        city_heading2     = create(:budget_heading, group: city,      name: "Investments Type2")
        district_heading1 = create(:budget_heading, group: districts, name: "District 1")
        district_heading2 = create(:budget_heading, group: districts, name: "District 2")

        city_investment1      = create(:budget_investment, :selected, heading: city_heading1)
        city_investment2      = create(:budget_investment, :selected, heading: city_heading1)
        district1_investment1 = create(:budget_investment, :selected, heading: district_heading1)
        district1_investment2 = create(:budget_investment, :selected, heading: district_heading1)
        district2_investment1 = create(:budget_investment, :selected, heading: district_heading2)

        visit budget_path(budget)
        click_link "City"
        click_link "Investments Type1"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content city_investment1.title
        expect(page).to have_content city_investment2.title

        visit budget_path(budget)

        click_link "Districts"
        click_link "District 1"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content district1_investment1.title
        expect(page).to have_content district1_investment2.title

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 2"

        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content district2_investment1.title
      end

      scenario "Redirect to first heading if there is only one" do
        city_heading      = create(:budget_heading, group: city,      name: "City")
        district_heading1 = create(:budget_heading, group: districts, name: "District 1")
        district_heading2 = create(:budget_heading, group: districts, name: "District 2")

        city_investment = create(:budget_investment, :selected, heading: city_heading)

        visit budget_path(budget)
        click_link "City"

        expect(page).to have_content city_investment.title
      end

    end

    context "Adding and Removing Investments" do

      scenario "Add a investment", :js do
        investment1 = create(:budget_investment, :selected, heading: new_york, price: 10000)
        investment2 = create(:budget_investment, :selected, heading: new_york, price: 20000)

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        add_to_ballot(investment1)

        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"
        end

        add_to_ballot(investment2)

        expect(page).to have_css("#amount-spent", text: "€30,000")
        expect(page).to have_css("#amount-available", text: "€970,000")

        within("#sidebar") do
          expect(page).to have_content investment2.title
          expect(page).to have_content "€20,000"
        end
      end

      scenario "Removing a investment", :js do
        investment = create(:budget_investment, :selected, heading: new_york, price: 10000)
        ballot = create(:budget_ballot, user: user, budget: budget)
        ballot.investments << investment

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        expect(page).to have_content investment.title
        expect(page).to have_css("#amount-spent", text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment.title
          expect(page).to have_content "€10,000"
        end

        within("#budget_investment_#{investment.id}") do
          find(".remove a").click
        end

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-available", text: "€1,000,000")

        within("#sidebar") do
          expect(page).not_to have_content investment.title
          expect(page).not_to have_content "€10,000"
        end
      end

      scenario "the Map shoud be visible before and after", :js do
        investment = create(:budget_investment, :selected, heading: new_york, price: 10000)

        visit budget_path(budget)
        click_link "States"
        click_link "New York"

        within("#sidebar") do
          expect(page).to have_content "OpenStreetMap"
        end

        add_to_ballot(investment)

        within("#sidebar") do
          expect(page).to have_content investment.title
          expect(page).to have_content "OpenStreetMap"
        end

        within("#budget_investment_#{investment.id}") do
          click_link "Remove vote"
        end

        within("#sidebar") do
          expect(page).not_to have_content investment.title
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

        investment1 = create(:budget_investment, :selected, heading: city_heading,      price: 10000)
        investment2 = create(:budget_investment, :selected, heading: district_heading1, price: 20000)
        investment3 = create(:budget_investment, :selected, heading: district_heading2, price: 30000)

        visit budget_path(budget)
        click_link "City"

        add_to_ballot(investment1)

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 1"

        expect(page).to have_css("#amount-spent", text: "€0")
        expect(page).to have_css("#amount-spent", text: "€1,000,000")

        add_to_ballot(investment2)

        expect(page).to have_css("#amount-spent",     text: "€20,000")
        expect(page).to have_css("#amount-available", text: "€980,000")

        within("#sidebar") do
          expect(page).to have_content investment2.title
          expect(page).to have_content "€20,000"

          expect(page).not_to have_content investment1.title
          expect(page).not_to have_content "€10,000"
        end

        visit budget_path(budget)
        click_link "City"

        expect(page).to have_css("#amount-spent",     text: "€10,000")
        expect(page).to have_css("#amount-available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content investment1.title
          expect(page).to have_content "€10,000"

          expect(page).not_to have_content investment2.title
          expect(page).not_to have_content "€20,000"
        end

        visit budget_path(budget)
        click_link "Districts"
        click_link "District 2"

        expect(page).to have_content("You have active votes in another heading: District 1")
      end
    end

    scenario "Display progress bar after first vote", :js do
      investment = create(:budget_investment, :selected, heading: new_york, price: 10000)

      visit budget_investments_path(budget, heading_id: new_york.id)

      expect(page).to have_content investment.title
      add_to_ballot(investment)

      within("#progress_bar") do
        expect(page).to have_css("#amount-spent", text: "€10,000")
      end
    end
  end

  context "Groups" do

    let!(:investment) { create(:budget_investment, :selected, heading: california) }

    background { login_as(user) }

    scenario "Select my heading", :js do
      visit budget_path(budget)
      click_link "States"
      click_link "California"

      add_to_ballot(investment)

      visit budget_path(budget)
      click_link "States"

      expect(page).to have_content "California"
      expect(page).to have_css("#budget_heading_#{california.id}.is-active")
    end

    scenario "Change my heading", :js do
      investment1 = create(:budget_investment, :selected, heading: california)
      investment2 = create(:budget_investment, :selected, heading: new_york)

      ballot = create(:budget_ballot, user: user, budget: budget)
      ballot.investments << investment1

      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{investment1.id}") do
        find(".remove a").click
      end

      visit budget_investments_path(budget, heading_id: new_york.id)

      add_to_ballot(investment2)

      visit budget_path(budget)
      click_link "States"
      expect(page).to have_css("#budget_heading_#{new_york.id}.is-active")
      expect(page).not_to have_css("#budget_heading_#{california.id}.is-active")
    end

    scenario "View another heading" do
      investment = create(:budget_investment, :selected, heading: california)

      ballot = create(:budget_ballot, user: user, budget: budget)
      ballot.investments << investment

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

      ballot = create(:budget_ballot, user: user, budget: budget)

      ballot.investments << investment1 << investment2 << investment3 << investment4 << investment5

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
      heading = create(:budget_heading, name: "District 1", group: group, price: 100)

      ballot = create(:budget_ballot, user: user, budget: budget)

      login_as(user)
      visit budget_ballot_path(budget)

      expect(page).to have_link "You have not voted on this group yet, go vote!", href: budget_group_path(budget, group)
    end

  end

  scenario "Removing investments from ballot", :js do
    investment = create(:budget_investment, :selected, price: 10, heading: new_york)
    ballot = create(:budget_ballot, user: user, budget: budget)
    ballot.investments << investment

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

    ballot = create(:budget_ballot, budget: budget, user: user)
    ballot.investments << investment1 << investment2

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
    investment = create(:budget_investment, :selected, heading: new_york, price: 10)

    login_as(user)
    visit budget_investments_path(budget, heading_id: new_york.id)
    add_to_ballot(investment)

    click_link "Check my ballot"

    expect(page).to have_content("You have voted one investment")

    within("#budget_investment_#{investment.id}") do
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
        find("div.ballot").hover
        expect(page).to have_content "You must Sign in or Sign up to continue."
        expect(page).to have_selector(".in-favor a", visible: false)
      end
    end

    scenario "User not verified", :js do
      unverified_user = create(:user)
      investment = create(:budget_investment, :selected, heading: new_york)

      login_as(unverified_user)
      visit budget_investments_path(budget, heading_id: new_york.id)

      within("#budget_investment_#{investment.id}") do
        find("div.ballot").hover
        expect(page).to have_content "Only verified users can vote on investments"
        expect(page).to have_selector(".in-favor a", visible: false)
      end
    end

    scenario "User is organization", :js do
      org = create(:organization)
      investment = create(:budget_investment, :selected, heading: new_york)

      login_as(org.user)
      visit budget_investments_path(budget, heading_id: new_york.id)

      within("#budget_investment_#{investment.id}") do
        find("div.ballot").hover
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
      investment = create(:budget_investment, feasibility: "undecided", heading: new_york)

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

      ballot = create(:budget_ballot, budget: budget, user: user)
      ballot.investments << bi1

      login_as(user)
      visit budget_investments_path(budget, heading: new_york)

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).to have_content("already voted a different heading")
        expect(page).to have_selector(".in-favor a", visible: false)
      end
    end

    scenario "Insufficient funds (on page load)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)

      ballot = create(:budget_ballot, budget: budget, user: user)
      ballot.investments << bi1

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: false)
      end
    end

    scenario "Insufficient funds (added after create)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi1.id}") do
        find("div.ballot").hover
        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: true)
      end

      add_to_ballot(bi1)

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: false)
      end

    end

    scenario "Insufficient funds (removed after destroy)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)

      ballot = create(:budget_ballot, budget: budget, user: user)
      ballot.investments << bi1

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: false)
      end

      within("#budget_investment_#{bi1.id}") do
        find(".remove a").click
        expect(page).to have_css ".add a"
      end

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: true)
      end
    end

    scenario "Insufficient funds (removed after destroying from sidebar)", :js do
      bi1 = create(:budget_investment, :selected, heading: california, price: 600)
      bi2 = create(:budget_investment, :selected, heading: california, price: 500)

      ballot = create(:budget_ballot, budget: budget, user: user)
      ballot.investments << bi1

      login_as(user)
      visit budget_investments_path(budget, heading_id: california.id)

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: false)
      end

      within("#budget_investment_#{bi1.id}_sidebar") do
        find(".icon-x").click
      end

      expect(page).not_to have_css "#budget_investment_#{bi1.id}_sidebar"

      within("#budget_investment_#{bi2.id}") do
        find("div.ballot").hover
        expect(page).not_to have_content("You have already assigned the available budget")
        expect(page).to have_selector(".in-favor a", visible: true)
      end
    end

    scenario "Edge case voting a non-elegible investment", :js do
      investment1 = create(:budget_investment, :selected, heading: new_york, price: 10000)

      login_as(user)
      visit budget_path(budget)
      click_link "States"
      click_link "New York"

      new_york.update(price: 10)

      within("#budget_investment_#{investment1.id}") do
        expect(page).to have_selector(".in-favor a", visible: true)
        find(".add a").click
        expect(page).not_to have_content "Remove"
        expect(page).to have_selector(".participation-not-allowed", visible: false)
        find("div.ballot").hover
        expect(page).to have_selector(".participation-not-allowed", visible: true)
        expect(page).to have_selector(".in-favor a", visible: false)
      end
    end

    scenario "Balloting is disabled when budget isn't in the balotting phase", :js do
      budget.update(phase: "accepting")

      bi1 = create(:budget_investment, :selected, heading: california, price: 600)

      login_as(user)

      visit budget_investments_path(budget, heading_id: california.id)
      within("#budget_investment_#{bi1.id}") do
        expect(page).not_to have_css("div.ballot")
      end
    end
  end
end
