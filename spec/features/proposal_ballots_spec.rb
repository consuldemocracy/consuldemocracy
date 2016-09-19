# coding: utf-8
require 'rails_helper'

feature 'Proposal ballots' do

  scenario 'Banner shows in proposal index' do
    create_featured_proposals

    visit proposals_path
    expect(page).to_not have_css("#next-voting")
    expect(page).to have_css("#featured-proposals")

    create_successfull_proposals

    visit proposals_path

    expect(page).to have_css("#next-voting")
    expect(page).to_not have_css("#featured-proposals")
  end

  scenario 'Successfull proposals do not show support buttons in index' do
    successfull_proposals = create_successfull_proposals

    visit proposals_path

    successfull_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_css(".supports")
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

  scenario 'Successfull proposals do not show support buttons in show' do
    successfull_proposals = create_successfull_proposals

    successfull_proposals.each do |proposal|
      visit proposal_path(proposal)
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_css(".supports")
        expect(page).to have_content "This proposal has reached the required supports"
      end
    end
  end

  scenario 'Successfull proposals are listed in the proposal ballots index' do
    successfull_proposals = create_successfull_proposals

    visit proposal_ballots_path

    successfull_proposals.each do |proposal|
      expect(page).to have_content(proposal.title)
    end
  end

  scenario 'Successfull proposals show create enquiry button to admin users' do
    successfull_proposals = create_successfull_proposals

    visit proposals_path

    successfull_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to_not have_link "Create Enquiry"
      end
    end

    login_as(create(:administrator).user)

    visit proposals_path

    successfull_proposals.each do |proposal|
      within("#proposal_#{proposal.id}_votes") do
        expect(page).to have_link "Create Enquiry"
      end
    end

  end

end

