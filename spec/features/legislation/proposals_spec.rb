require 'rails_helper'
require 'sessions_helper'

feature 'Legislation Proposals' do

  let(:user)     { create(:user) }
  let(:user2)    { create(:user) }
  let(:process)  { create(:legislation_process) }
  let(:proposal) { create(:legislation_proposal) }

  context "Concerns" do
    it_behaves_like 'notifiable in-app', Legislation::Proposal
  end

  scenario "Only one menu element has 'active' CSS selector" do
    visit legislation_process_proposal_path(proposal.process, proposal)

    within('#navigation_bar') do
      expect(page).to have_css('.is-active', count: 1)
    end
  end

  scenario 'Each user as a different and consistent random proposals order', :js do
    create_list(:legislation_proposal, 10, process: process)

    in_browser(:one) do
      login_as user
      visit legislation_process_proposals_path(process)
      @first_user_proposals_order = legislation_proposals_order
    end

    in_browser(:two) do
      login_as user2
      visit legislation_process_proposals_path(process)
      @second_user_proposals_order = legislation_proposals_order
    end

    expect(@first_user_proposals_order).not_to eq(@second_user_proposals_order)

    in_browser(:one) do
      visit legislation_process_proposals_path(process)
      expect(legislation_proposals_order).to eq(@first_user_proposals_order)
    end

    in_browser(:two) do
      visit legislation_process_proposals_path(process)
      expect(legislation_proposals_order).to eq(@second_user_proposals_order)
    end
  end

  def legislation_proposals_order
    all("[id^='legislation_proposal_']").collect { |e| e[:id] }
  end

  scenario "Create a legislation proposal with an image", :js do
    create(:legislation_proposal, process: process)

    login_as user

    visit new_legislation_process_proposal_path(process)

    fill_in 'Proposal title', with: 'Legislation proposal with image'
    fill_in 'Proposal summary', with: 'Including an image on a legislation proposal'
    imageable_attach_new_file(create(:image), Rails.root.join('spec/fixtures/files/clippy.jpg'))
    check 'legislation_proposal_terms_of_service'
    click_button 'Create proposal'

    expect(page).to have_content 'Legislation proposal with image'
    expect(page).to have_content 'Including an image on a legislation proposal'
    expect(page).to have_css("img[alt='#{Legislation::Proposal.last.image.title}']")
  end
end
