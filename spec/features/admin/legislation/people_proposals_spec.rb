require "rails_helper"

feature "Admin collaborative legislation" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do

    scenario "Displaying legislation people and groups proposals" do
      people_proposal = create(:legislation_people_proposal,
                              :with_contact_info,
                              cached_votes_score: 10)

      visit admin_legislation_process_people_proposals_path(people_proposal.legislation_process_id)

      expect(page).to have_content("There is 1 people proposal")

      within "#legislation_people_proposal_#{people_proposal.id}" do
        expect(page).to have_content(people_proposal.title)
        expect(page).to have_content(people_proposal.id)
        expect(page).to have_content(people_proposal.phone)
        expect(page).to have_content(people_proposal.email)
        expect(page).to have_content(people_proposal.cached_votes_score)
        expect(page).to have_content("Validate")
        expect(page).to have_content("Show")
        expect(page).to have_content("Edit")
        expect(page).to have_content("Select")
      end
    end

    scenario "Validating legislation people_proposals", :js do
      people_proposal = create(:legislation_people_proposal, cached_votes_score: 10)

      visit admin_legislation_process_people_proposals_path(people_proposal.legislation_process_id)

      within "#legislation_people_proposal_#{people_proposal.id}" do
        click_link "Validate"

        expect(page).to have_content("Validated")
      end
    end

    scenario "Selecting legislation people_proposals", :js do
      people_proposal = create(:legislation_people_proposal, cached_votes_score: 10)

      visit admin_legislation_process_people_proposals_path(people_proposal.legislation_process_id)

      within "#legislation_people_proposal_#{people_proposal.id}" do
        click_link "Select"

        expect(page).to have_content("Selected")
      end
    end

    scenario "Sorting legislation people_proposals by title", js: true do
      process = create(:legislation_process)
      create(:legislation_people_proposal, title: "bbbb", legislation_process_id: process.id)
      create(:legislation_people_proposal, title: "aaaa", legislation_process_id: process.id)
      create(:legislation_people_proposal, title: "cccc", legislation_process_id: process.id)

      visit admin_legislation_process_people_proposals_path(process.id)
      select "Name", from: "order-selector-participation"

      within("#legislation_people_proposals_list") do
        within all(".legislation_people_proposal")[0] { expect(page).to have_content("aaaa") }
        within all(".legislation_people_proposal")[1] { expect(page).to have_content("bbbb") }
        within all(".legislation_people_proposal")[2] { expect(page).to have_content("cccc") }
      end
    end

    scenario "Sorting legislation people_proposals by supports", js: true do
      process = create(:legislation_process)
      create(:legislation_people_proposal,
              cached_votes_score: 10,
              legislation_process_id: process.id)
      create(:legislation_people_proposal,
              cached_votes_score: 30,
              legislation_process_id: process.id)
      create(:legislation_people_proposal,
              cached_votes_score: 20,
              legislation_process_id: process.id)

      visit admin_legislation_process_people_proposals_path(process.id)
      select "Total supports", from: "order-selector-participation"

      within("#legislation_people_proposals_list") do
        within all(".legislation_people_proposal")[0] { expect(page).to have_content("30") }
        within all(".legislation_people_proposal")[1] { expect(page).to have_content("20") }
        within all(".legislation_people_proposal")[2] { expect(page).to have_content("10") }
      end
    end

    scenario "Sorting legislation people_proposals by Id", js: true do
      process = create(:legislation_process)
      people_proposal1 = create(:legislation_people_proposal,
                                  title: "bbbb",
                                  legislation_process_id: process.id)
      people_proposal2 = create(:legislation_people_proposal,
                                  title: "aaaa",
                                  legislation_process_id: process.id)
      people_proposal3 = create(:legislation_people_proposal,
                                  title: "cccc",
                                  legislation_process_id: process.id)

      visit admin_legislation_process_people_proposals_path(process.id, order: :title)
      select "Id", from: "order-selector-participation"

      within("#legislation_people_proposals_list") do
        within all(".legislation_people_proposal")[0] do
          expect(page).to have_content(people_proposal1.id)
        end
        within all(".legislation_people_proposal")[1] do
          expect(page).to have_content(people_proposal2.id)
        end
        within all(".legislation_people_proposal")[2] do
          expect(page).to have_content(people_proposal3.id)
        end
      end
    end

    scenario "Show legislation people_proposals", js: true do
      process = create(:legislation_process)
      people_proposal = create(:legislation_people_proposal,
                                cached_votes_score: 10,
                                legislation_process_id: process.id)

      visit admin_legislation_process_people_proposals_path(process.id)
      within "#legislation_people_proposal_#{people_proposal.id}" do
        click_link "Show"
        expected_path = admin_legislation_process_people_proposal_path(process, people_proposal)

        expect(page).to have_current_path(expected_path)
      end
    end

    scenario "Edit legislation people_proposals", js: true do
      process = create(:legislation_process)
      people_proposal = create(:legislation_people_proposal,
                                cached_votes_score: 10,
                                legislation_process_id: process.id)

      visit admin_legislation_process_people_proposals_path(process.id)
      within "#legislation_people_proposal_#{people_proposal.id}" do
        click_link "Edit"
        expected_path = edit_admin_legislation_process_people_proposal_path(process,
                          people_proposal)

        expect(page).to have_current_path(expected_path)
      end
    end

    scenario "Add new proposal is visible" do
      process = create(:legislation_process)

      visit admin_legislation_process_people_proposals_path(process.id)
      click_link "New People and Group proposal"
      expected_path = new_admin_legislation_process_people_proposal_path(process.id)

      expect(page).to have_current_path(expected_path)
    end
  end

  context "Show people proposal" do
    scenario "Display legislation people and group proposal" do
      people_proposal = create(:legislation_people_proposal,
                              :with_contact_info,
                              cached_votes_score: 10)
      process = people_proposal.process

      visit admin_legislation_process_people_proposal_path(process, people_proposal)

      expect(page).to have_content(process.title)
      expect(page).to have_content(people_proposal.title)
    end
  end

  context "New people proposal" do
    scenario "Create a new people and group proposal" do
      process = create(:legislation_process)

      visit edit_admin_legislation_process_path(process)

      click_link "People and Groups"

      expect(page).to have_content("There are no proposals")

      click_link "New People and Group proposal"

      fill_in "Name", with: "Jon Snow"
      fill_in "Phone", with: "123456789"
      fill_in "Proposal summary", with: "can kill white walkers"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      expect(page).to have_current_path(admin_legislation_process_people_proposals_path(process))
      expect(page).to have_content("There is 1 people proposal")
      expect(page).to have_content "Jon Snow"
      expect(page).to have_content "123456789"
    end
  end

  context "Edit people proposal" do
    scenario "Edit a people and group proposal fields" do
      process = create(:legislation_process)
      people_proposal = create(:legislation_people_proposal,
                                cached_votes_score: 10,
                                legislation_process_id: process.id)

      visit edit_admin_legislation_process_people_proposal_path(process, people_proposal)

      expect(page).to have_content(people_proposal.title)
      expect(page).to have_content(people_proposal.phone)
      expect(page).to have_content(people_proposal.summary)

      fill_in "Name", with: "Jon Snow"
      fill_in "Phone", with: "123456789"
      fill_in "Proposal summary", with: "can kill white walkers"

      click_button "Save changes"

      expect(page).to have_current_path(admin_legislation_process_people_proposals_path(process))
      expect(page).to have_content("There is 1 people proposal")
      expect(page).to have_content "Jon Snow"
      expect(page).to have_content "123456789"
    end
  end

end
