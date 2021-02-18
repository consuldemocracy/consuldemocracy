require "rails_helper"

describe "Admin collaborative legislation", :admin do
  context "Index" do
    scenario "Displaying legislation proposals" do
      proposal = create(:legislation_proposal, cached_votes_score: 10)

      visit admin_legislation_process_proposals_path(proposal.legislation_process_id)

      within "#legislation_proposal_#{proposal.id}" do
        expect(page).to have_content(proposal.title)
        expect(page).to have_content(proposal.id)
        expect(page).to have_content(proposal.cached_votes_score)
        expect(page).to have_content("Select")
      end
    end

    scenario "Selecting legislation proposals", :js do
      proposal = create(:legislation_proposal, cached_votes_score: 10)

      visit admin_legislation_process_proposals_path(proposal.legislation_process_id)
      click_link "Select"

      within "#legislation_proposal_#{proposal.id}" do
        expect(page).to have_content("Selected")
      end
    end

    scenario "Sorting legislation proposals by title", js: true do
      process = create(:legislation_process)
      create(:legislation_proposal, title: "bbbb", legislation_process_id: process.id)
      create(:legislation_proposal, title: "aaaa", legislation_process_id: process.id)
      create(:legislation_proposal, title: "cccc", legislation_process_id: process.id)

      visit admin_legislation_process_proposals_path(process.id)
      select "Title", from: "order-selector-participation"

      within("#legislation_proposals_list") do
        within all(".legislation_proposal")[0] { expect(page).to have_content("aaaa") }
        within all(".legislation_proposal")[1] { expect(page).to have_content("bbbb") }
        within all(".legislation_proposal")[2] { expect(page).to have_content("cccc") }
      end
    end

    scenario "Sorting legislation proposals by supports", js: true do
      process = create(:legislation_process)
      create(:legislation_proposal, cached_votes_score: 10, legislation_process_id: process.id)
      create(:legislation_proposal, cached_votes_score: 30, legislation_process_id: process.id)
      create(:legislation_proposal, cached_votes_score: 20, legislation_process_id: process.id)

      visit admin_legislation_process_proposals_path(process.id)
      select "Total supports", from: "order-selector-participation"

      within("#legislation_proposals_list") do
        within all(".legislation_proposal")[0] { expect(page).to have_content("30") }
        within all(".legislation_proposal")[1] { expect(page).to have_content("20") }
        within all(".legislation_proposal")[2] { expect(page).to have_content("10") }
      end
    end

    scenario "Sorting legislation proposals by Id", js: true do
      process = create(:legislation_process)
      proposal1 = create(:legislation_proposal, title: "bbbb", legislation_process_id: process.id)
      proposal2 = create(:legislation_proposal, title: "aaaa", legislation_process_id: process.id)
      proposal3 = create(:legislation_proposal, title: "cccc", legislation_process_id: process.id)

      visit admin_legislation_process_proposals_path(process.id, order: :title)
      select "Id", from: "order-selector-participation"

      within("#legislation_proposals_list") do
        within all(".legislation_proposal")[0] { expect(page).to have_content(proposal1.id) }
        within all(".legislation_proposal")[1] { expect(page).to have_content(proposal2.id) }
        within all(".legislation_proposal")[2] { expect(page).to have_content(proposal3.id) }
      end
    end
  end
end
