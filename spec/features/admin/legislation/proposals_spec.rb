require 'rails_helper'

feature 'Admin legislation processes' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do

    scenario 'Displaying legislation proposals' do
      proposal = create(:legislation_proposal, cached_votes_up: 10)
      visit admin_legislation_process_proposals_path(proposal.legislation_process_id)
      within "#legislation_proposal_#{proposal.id}" do
        expect(page).to have_content(proposal.title)
        expect(page).to have_content(proposal.id)
        expect(page).to have_content(proposal.cached_votes_up)
        expect(page).to have_content('Select')
      end
    end

    scenario 'Selecting legislation proposals', :js do
      proposal = create(:legislation_proposal, cached_votes_up: 10)
      visit admin_legislation_process_proposals_path(proposal.legislation_process_id)

      click_link 'Select'
      within "#legislation_proposal_#{proposal.id}" do
        expect(page).to have_content('Selected')
      end
    end

    scenario 'Sorting legislation proposals by title', js: true do
      legislation_process = create(:legislation_process)
      create(:legislation_proposal, title: 'bbbb', cached_votes_up: 10, legislation_process_id: legislation_process.id)
      create(:legislation_proposal, title: 'aaaa', cached_votes_up: 20, legislation_process_id: legislation_process.id)
      create(:legislation_proposal, title: 'cccc', cached_votes_up: 30, legislation_process_id: legislation_process.id)
      visit admin_legislation_process_proposals_path(legislation_process.id)

      select "Title", from: "order-selector-participation"

      within('#proposals_table') do
        within(:xpath, "//tbody/tr[1]") do
          expect(page).to have_content('aaaa')
        end
        within(:xpath, "//tbody/tr[2]") do
          expect(page).to have_content('bbbb')
        end
        within(:xpath, "//tbody/tr[3]") do
          expect(page).to have_content('cccc')
        end
      end
    end

    scenario 'Sorting legislation proposals by supports', js: true do
      legislation_process = create(:legislation_process)
      create(:legislation_proposal, title: 'bbbb', cached_votes_up: 10, legislation_process_id: legislation_process.id)
      create(:legislation_proposal, title: 'aaaa', cached_votes_up: 20, legislation_process_id: legislation_process.id)
      create(:legislation_proposal, title: 'cccc', cached_votes_up: 30, legislation_process_id: legislation_process.id)
      visit admin_legislation_process_proposals_path(legislation_process.id)

      select "Supports", from: "order-selector-participation"

      within('#proposals_table') do
        within(:xpath, "//tbody/tr[1]") { expect(page).to have_content('30') }
        within(:xpath, "//tbody/tr[2]") { expect(page).to have_content('20') }
        within(:xpath, "//tbody/tr[3]") { expect(page).to have_content('10') }
      end
    end

    scenario 'Sorting legislation proposals by Id', js: true do
      legislation_process = create(:legislation_process)
      proposal1 = create(:legislation_proposal, title: 'bbbb', cached_votes_up: 10, legislation_process_id: legislation_process.id)
      proposal2 = create(:legislation_proposal, title: 'aaaa', cached_votes_up: 20, legislation_process_id: legislation_process.id)
      proposal3 = create(:legislation_proposal, title: 'cccc', cached_votes_up: 30, legislation_process_id: legislation_process.id)
      visit admin_legislation_process_proposals_path(legislation_process.id)

      select "Id", from: "order-selector-participation"

      within('#proposals_table') do
        within(:xpath, "//tbody/tr[1]") do
          expect(page).to have_content(proposal1.id)
        end
        within(:xpath, "//tbody/tr[2]") do
          expect(page).to have_content(proposal2.id)
        end
        within(:xpath, "//tbody/tr[3]") do
          expect(page).to have_content(proposal3.id)
        end
      end
    end
  end

end