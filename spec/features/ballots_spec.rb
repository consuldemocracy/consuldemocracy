require 'rails_helper'

feature 'Ballots' do

  background do
    skip 'Spending Proposals now redirects to its associated Budget Investment'
    Setting["feature.spending_proposals"] = true
    Setting['feature.spending_proposal_features.phase3'] = true
    Setting['feature.spending_proposal_features.final_voting_allowed'] ||= true
  end

  context "Voting" do
    let!(:user) { create(:user, :level_two) }

    background do
      login_as(user)
      visit welcome_spending_proposals_path
    end

    context "City" do

      scenario "Add a proposal", :js do
        sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
        sp2 = create(:spending_proposal, :feasible, :finished, price: 20000)

        click_link "Vote city proposals"

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"
        end

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$30,000")
        expect(page).to have_css("#amount-available", text: "$23,970,000")

        within("#sidebar") do
          expect(page).to have_content sp2.title
          expect(page).to have_content "$20,000"
        end
      end

      scenario "Remove a proposal", :js do
        sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
        ballot = create(:ballot, user: user, spending_proposals: [sp1])

        click_link "Vote city proposals"

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"
        end

        within("#spending_proposal_#{sp1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$0")
        expect(page).to have_css("#amount-available", text: "$24,000,000")

        within("#sidebar") do
          expect(page).to_not have_content sp1.title
          expect(page).to_not have_content "$10,000"
        end
      end

    end

    context 'District' do

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

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$3,237,830")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"
        end

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$30,000")
        expect(page).to have_css("#amount-available", text: "$3,217,830")

        within("#sidebar") do
          expect(page).to have_content sp2.title
          expect(page).to have_content "$20,000"
        end
      end

      scenario "Remove a proposal", :js do
        carabanchel = create(:geozone, name: "Carabanchel")

        sp1 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 10000)
        ballot = create(:ballot, user: user, geozone: carabanchel, spending_proposals: [sp1])

        click_link "Vote district proposals"
        click_link carabanchel.name

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$3,237,830")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"
        end

        within("#spending_proposal_#{sp1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$0")
        expect(page).to have_css("#amount-available", text: "$3,247,830")

        within("#sidebar") do
          expect(page).to_not have_content sp1.title
          expect(page).to_not have_content "$10,000"
        end
      end

    end

    context "City and District" do

      xscenario "Independent progress bar for city and district proposals", :js do
        carabanchel = create(:geozone, name: "Carabanchel")

        sp1 = create(:spending_proposal, :feasible, :finished, geozone: nil,        price: 10000)
        sp2 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 20000)

        click_link "Vote city proposals"

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
          expect(page).to have_content "Remove"
        end

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"
        end

        visit spending_proposals_path(geozone: carabanchel)

        expect(page).to have_css("#amount-spent", text: "$0")
        expect(page).to have_css("#amount-spent", text: "$3,247,830")

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
          expect(page).to have_content "Remove"
        end

        visit spending_proposals_path(geozone: carabanchel)

        expect(page).to have_css("#amount-spent", text: "$20,000")
        expect(page).to have_css("#amount-available", text: "$3,227,830")

        within("#sidebar") do
          expect(page).to have_content sp2.title
          expect(page).to have_content "$20,000"

          expect(page).to_not have_content sp1.title
          expect(page).to_not have_content "$10,000"
        end

        click_link "Spending proposals"
        click_link "Vote city proposals"

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#sidebar") do
          expect(page).to have_content sp1.title
          expect(page).to have_content "$10,000"

          expect(page).to_not have_content sp2.title
          expect(page).to_not have_content "$20,000"
        end
      end
    end

    scenario "Display progress bar after first district vote", :js do
      carabanchel = create(:geozone, name: "Carabanchel")

      sp1 = create(:spending_proposal, :feasible, :finished, geozone: carabanchel, price: 10000)

      click_link "Vote district proposals"
      click_link carabanchel.name

      within("#spending_proposal_#{sp1.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove"
      end

      within("#progress_bar") do
        expect(page).to have_css("#amount-spent", text: "$10,000")
      end
    end
  end

  context "Choosing my district" do
    let!(:user) { create(:user, :level_two) }

    background do
      login_as(user)
      visit welcome_spending_proposals_path
    end

    scenario 'Select my district', :js do
      california = create(:geozone)
      new_york = create(:geozone)
      sp1 = create(:spending_proposal, :feasible, :finished, geozone: california)

      click_link "Vote district proposals"
      click_link california.name

      within("#spending_proposal_#{sp1.id}") do
        find('.add a').trigger('click')
      end

      visit select_district_path
      expect(page).to have_css("#geozone_#{california.id}.active")
    end

    scenario 'Change my district', :js do
      california = create(:geozone)
      new_york = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, geozone: california)
      sp2 = create(:spending_proposal, :feasible, :finished, geozone: new_york)

      create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

      visit spending_proposals_path(geozone: california)

      within("#spending_proposal_#{sp1.id}") do
        find('.remove a').trigger('click')
      end

      visit spending_proposals_path(geozone: new_york)

      within("#spending_proposal_#{sp2.id}") do
        find('.add a').trigger('click')
      end

      visit select_district_path
      expect(page).to have_css("#geozone_#{new_york.id}.active")
      expect(page).to_not have_css("#geozone_#{california.id}.active")
    end

    scenario 'View another district' do
      california = create(:geozone)
      new_york = create(:geozone)

      sp1 = create(:spending_proposal, :feasible, :finished, geozone: california)
      sp2 = create(:spending_proposal, :feasible, :finished, geozone: new_york)

      create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

      visit spending_proposals_path(geozone: new_york)

      expect(page).to_not have_css "#progressbar"
      expect(page).to have_content "You have active votes in another district:"
      expect(page).to have_link california.name, href: spending_proposals_path(geozone: california)
    end

  end

  context 'Showing the ballot' do

    scenario 'Displaying the correct count & amount' do
      user = create(:user, :level_two)
      geozone = create(:geozone, name: "Carabanchel")
      ballot = create(:ballot, user: user, geozone: geozone)

      ballot.spending_proposals =
        create_list(:spending_proposal, 2, :feasible, :finished, price: 10) +
        create_list(:spending_proposal, 3, :feasible, :finished, price: 5, geozone: geozone)

      login_as(user)
      visit ballot_path

      expect(page).to have_content("You voted 5 proposals")
      within("#city_wide") { expect(page).to have_content "$20" }
      within("#district_wide") { expect(page).to have_content "$15" }
    end

  end

  scenario 'Removing spending proposals from ballot', :js do
    user = create(:user, :level_two)
    ballot = create(:ballot, user: user)
    sp = create(:spending_proposal, :feasible, :finished, price: 10)
    ballot.spending_proposals = [sp]

    login_as(user)
    visit ballot_path

    expect(page).to have_content("You voted one proposal")

    within("#spending_proposal_#{sp.id}") do
      find(".remove-investment-project").trigger('click')
    end

    expect(current_path).to eq(ballot_path)
    expect(page).to have_content("You voted 0 proposals")
  end

  scenario 'Removing spending proposals from ballot (sidebar)', :js do
    user = create(:user, :level_two)
    sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
    sp2 = create(:spending_proposal, :feasible, :finished, price: 20000)

    ballot = create(:ballot, user: user, spending_proposals: [sp1, sp2])

    login_as(user)
    visit spending_proposals_path(geozone: 'all')

    expect(page).to have_css("#amount-spent", text: "$30,000")
    expect(page).to have_css("#amount-available", text: "$23,970,000")

    within("#sidebar") do
      expect(page).to have_content sp1.title
      expect(page).to have_content "$10,000"

      expect(page).to have_content sp2.title
      expect(page).to have_content "$20,000"
    end

    within("#sidebar #spending_proposal_#{sp1.id}_sidebar") do
      find(".remove-investment-project").trigger('click')
    end

    expect(page).to have_css("#amount-spent", text: "$20,000")
    expect(page).to have_css("#amount-available", text: "$23,980,000")

    within("#sidebar") do
      expect(page).to_not have_content sp1.title
      expect(page).to_not have_content "$10,000"

      expect(page).to have_content sp2.title
      expect(page).to have_content "$20,000"
    end
  end

  scenario 'Removing spending proposals from ballot (sidebar)', :js do
    user = create(:user, :level_two)
    sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
    sp2 = create(:spending_proposal, :feasible, :finished, price: 20000)

    ballot = create(:ballot, user: user, spending_proposals: [sp1, sp2])

    login_as(user)
    visit spending_proposals_path(geozone: 'all')

    expect(page).to have_css("#amount-spent", text: "$30,000")
    expect(page).to have_css("#amount-available", text: "$23,970,000")

    within("#sidebar") do
      expect(page).to have_content sp1.title
      expect(page).to have_content "$10,000"

      expect(page).to have_content sp2.title
      expect(page).to have_content "$20,000"
    end

    within("#sidebar #spending_proposal_#{sp1.id}_sidebar") do
      find(".remove-investment-project").trigger('click')
    end

    expect(page).to have_css("#amount-spent", text: "$20,000")
    expect(page).to have_css("#amount-available", text: "$23,980,000")

    within("#sidebar") do
      expect(page).to_not have_content sp1.title
      expect(page).to_not have_content "$10,000"

      expect(page).to have_content sp2.title
      expect(page).to have_content "$20,000"
    end
  end

  context 'Permissions' do

    scenario 'User not logged in', :js do
      spending_proposal = create(:spending_proposal, :feasible, :finished)

      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_you_need_to_sign_in
      end
    end

    scenario 'User not verified', :js do
      user = create(:user)
      spending_proposal = create(:spending_proposal, :feasible, :finished)

      login_as(user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_only_verified_can_vote_proposals
      end
    end

    xscenario 'User is organization', :js do
      org = create(:organization)
      spending_proposal = create(:spending_proposal, :feasible, :finished)

      login_as(org.user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_organizations_cannot_vote
      end
    end

    scenario 'Spending proposal unfeasible' do
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, :finished, feasible: false)

      login_as(user)
      visit spending_proposals_path(unfeasible: 1)

      within("#spending_proposal_#{spending_proposal.id}") do
        expect(page).to_not have_css("div.ballot")
      end
    end

    scenario 'Spending proposal with feasibility undecided are not shown' do
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, :finished, feasible: nil)

      login_as(user)
      visit spending_proposals_path

      within("#investment-projects") do
        expect(page).to_not have_css("div.ballot")
        expect(page).to_not have_css("#spending_proposal_#{spending_proposal.id}")
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

    scenario "Voting proposals when delegating", :js do
      forum = create(:forum, name: 'hydra')
      user = create(:user, :level_two, representative_id: forum.id)
      sp = create(:spending_proposal, :feasible, :finished)

      login_as(user)
      visit forums_path
      expect(page).to have_content("You are delegating your votes on hydra")

      visit spending_proposals_path(geozone: 'all')

      within("#spending_proposal_#{sp.id}") do
        find('.add a').trigger('click')
        expect(page).to have_content "Remove vote"
      end

      visit forums_path
      expect(page).to_not have_content("You are delegating your votes on hydra")
    end

  end
end
