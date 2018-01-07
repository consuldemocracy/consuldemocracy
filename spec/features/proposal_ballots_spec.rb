# coding: utf-8
require 'rails_helper'

describe 'Proposal ballots' do

  it 'Successful proposals do not show support buttons in index' do
    successful_proposals = create_successful_proposals

    visit proposals_path

    successful_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

  it 'Successful proposals do not show support buttons in show' do
    successful_proposals = create_successful_proposals

    successful_proposals.each do |proposal|
      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

end

