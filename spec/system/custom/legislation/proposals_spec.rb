require "rails_helper"
require "sessions_helper"

describe "Legislation Proposals" do
  let(:user)     { create(:user) }
  let(:process)  { create(:legislation_process) }

  scenario "Create a legislation proposal with an image" do
    login_as user

    visit new_legislation_process_proposal_path(process)

    fill_in "Proposal title", with: "Legislation proposal with image"
    fill_in "Proposal summary", with: "Including an image on a legislation proposal"
    imageable_attach_new_file(file_fixture("clippy.jpg"))
    click_button "Create proposal"

    expect(page).to have_content "Legislation proposal with image"
    expect(page).to have_content "Including an image on a legislation proposal"
    expect(page).to have_css "img[alt='clippy.jpg']"
  end

  scenario "Can visit a legislation proposal from image link" do
    proposal = create(:legislation_proposal, :with_image, process: process)

    visit legislation_process_proposals_path(process)

    within("#legislation_proposal_#{proposal.id}") do
      find("#image").click
    end

    expect(page).to have_current_path(legislation_process_proposal_path(proposal.process, proposal))
  end
end
