require 'rails_helper'

feature 'Ballots' do

  background do
    Setting['feature.spending_proposal_features.phase3'] = true
    Setting['feature.spending_proposal_features.final_voting_allowed'] = true
  end

  context "Voting" do
    let!(:user) { create(:user, :level_two) }

    background do
      login_as(user)
      visit welcome_spending_proposals_path
    end

    context "City" do

      scenario "Add a proposal", :js do
        sp1 = create(:spending_proposal, feasible: true, price: 10000)
        sp2 = create(:spending_proposal, feasible: true, price: 20000)

        click_link "Vote city proposals"

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$30,000")
        expect(page).to have_css("#amount-available", text: "$23,970,000")
      end

      scenario "Remove a proposal", :js do
        sp1 = create(:spending_proposal, feasible: true, price: 10000)
        ballot = create(:ballot, user: user, spending_proposals: [sp1])

        click_link "Vote city proposals"

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#spending_proposal_#{sp1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$0")
        expect(page).to have_css("#amount-available", text: "$24,000,000")
      end

    end

    context 'District' do

      scenario "Add a proposal", :js do
        california = create(:geozone)

        sp1 = create(:spending_proposal, geozone: california, feasible: true, price: 10000)
        sp2 = create(:spending_proposal, geozone: california, feasible: true, price: 20000)

        click_link "Vote district proposals"
        click_link california.name

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$30,000")
        expect(page).to have_css("#amount-available", text: "$23,970,000")
      end

      scenario "Remove a proposal", :js do
        california = create(:geozone)

        sp1 = create(:spending_proposal, geozone: california, feasible: true, price: 10000)
        ballot = create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

        click_link "Vote district proposals"
        click_link california.name

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        within("#spending_proposal_#{sp1.id}") do
          find('.remove a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$0")
        expect(page).to have_css("#amount-available", text: "$24,000,000")
      end

    end

    context "City and District" do

      scenario "Independent progress bar for city and district proposals", :js do
        california = create(:geozone)

        sp1 = create(:spending_proposal, geozone: nil,        feasible: true, price: 10000)
        sp2 = create(:spending_proposal, geozone: california, feasible: true, price: 20000)

        click_link "Vote city proposals"

        within("#spending_proposal_#{sp1.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")

        visit spending_proposals_path(geozone: california)

        expect(page).to_not have_css("#amount-spent")

        within("#spending_proposal_#{sp2.id}") do
          find('.add a').trigger('click')
        end

        expect(page).to have_css("#amount-spent", text: "$20,000")
        expect(page).to have_css("#amount-available", text: "$23,980,000")

        click_link "Participatory budgeting"
        click_link "Vote city proposals"

        expect(page).to have_css("#amount-spent", text: "$10,000")
        expect(page).to have_css("#amount-available", text: "$23,990,000")
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
      sp1 = create(:spending_proposal, geozone: california, feasible: true)

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

      sp1 = create(:spending_proposal, geozone: california, feasible: true)
      sp2 = create(:spending_proposal, geozone: new_york,   feasible: true)

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

      sp1 = create(:spending_proposal, geozone: california, feasible: true)
      sp2 = create(:spending_proposal, geozone: new_york,   feasible: true)

      create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

      visit spending_proposals_path(geozone: new_york)

      expect(page).to_not have_css "#progressbar"
      expect(page).to have_content "You have active votes in another district."
      expect(page).to have_link california.name, href: spending_proposals_path(geozone: california)
    end

  end

  context 'Showing the ballot' do

    scenario 'Displaying the correct count & amount' do
      user = create(:user)
      ballot = create(:ballot, user: user)
      geozone = create(:geozone)

      ballot.spending_proposals =
        create_list(:spending_proposal, 2, price: 10) +
        create_list(:spending_proposal, 3, price: 5, geozone: geozone)

      login_as(user)
      visit ballot_path

      expect(page).to have_content("You voted 5 proposals with a total cost of 35")
      within("#city_wide") { expect(page).to have_content "20€" }
      within("#district_wide") { expect(page).to have_content "15€" }
    end

  end

  context 'Permissions' do

    scenario 'User not logged in', :js do
      spending_proposal = create(:spending_proposal)

      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_you_need_to_sign_in
      end
    end

    scenario 'User not verified', :js do
      user = create(:user)
      spending_proposal = create(:spending_proposal)

      login_as(user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_only_verified_can_vote_proposals
      end
    end

    scenario 'User is organization', :js do
      org = create(:organization)
      spending_proposal = create(:spending_proposal)

      login_as(org.user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_organizations_cannot_vote
      end
    end

    scenario 'Spending proposal unfeasible', :js do
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, feasible: false, valuation_finished: true)

      login_as(user)
      visit spending_proposals_path(unfeasible: 1)

      within("#spending_proposal_#{spending_proposal.id}") do
        expect(page).to_not have_css("div.ballot")
      end
    end

    scenario 'Wrong district', :js do
      user = create(:user, :level_two)
      california = create(:geozone)
      new_york = create(:geozone)

      sp1 = create(:spending_proposal, geozone: california, feasible: true)
      sp2 = create(:spending_proposal, geozone: new_york,   feasible: true)

      create(:ballot, user: user, geozone: california, spending_proposals: [sp1])

      login_as(user)
      visit spending_proposals_path(geozone: new_york)

      within("#spending_proposal_#{sp2.id}") do
        find("div.ballot").hover
        expect_message_already_voted_in_another_geozone(california)
      end
    end

  end

end
