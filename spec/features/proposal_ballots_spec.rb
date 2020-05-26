require "rails_helper"

describe "Proposal ballots" do
  scenario "Successful proposals do not show support buttons in index" do
    successful_proposals = create_successful_proposals

    visit proposals_path

    successful_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes .supports .progress") do
        expect(page).to have_content "100% / 100%"
      end
    end
  end

  scenario "Successful proposals do not show support buttons in show" do
    successful_proposals = create_successful_proposals

    successful_proposals.each do |proposal|
      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}_votes .supports .progress") do
        expect(page).to have_content "100% / 100%"
      end
    end
  end
end
