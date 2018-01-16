require 'rails_helper'
require 'sessions_helper'

feature 'Legislation Proposals' do

  context "Concerns" do
    it_behaves_like 'notifiable in-app', Legislation::Proposal
  end

  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:process) { create(:legislation_process) }

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

  scenario 'Random order maintained with pagination', :js do
    create_list(:legislation_proposal, (Kaminari.config.default_per_page + 2), process: process)

    login_as user
    visit legislation_process_proposals_path(process)
    first_page_proposals_order = legislation_proposals_order

    click_link 'Next'
    expect(page).to have_content "You're on page 2"
    second_page_proposals_order = legislation_proposals_order

    click_link 'Previous'
    expect(page).to have_content "You're on page 1"

    expect(legislation_proposals_order).to eq(first_page_proposals_order)
    expect(first_page_proposals_order & second_page_proposals_order).to eq([])
  end

  def legislation_proposals_order
    all("[id^='legislation_proposal_']").collect { |e| e[:id] }
  end

end
