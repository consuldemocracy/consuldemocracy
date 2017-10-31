require 'rails_helper'
require 'sessions_helper'

feature 'Legislation Proposals' do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:process) { create(:legislation_process) }

  scenario 'Each user as a different and consistent random proposals order', :js do
    create_list(:legislation_proposal, 10, process: process)

    in_browser(:one) do
      login_as user
      visit legislation_process_proposals_path(process)
      @first_user_proposals_order = all("[id^='legislation_proposal_']").collect { |e| e[:id] }
    end

    in_browser(:two) do
      login_as user2
      visit legislation_process_proposals_path(process)
      @second_user_proposals_order = all("[id^='legislation_proposal_']").collect { |e| e[:id] }
    end

    expect(@first_user_proposals_order).not_to eq(@second_user_proposals_order)

    in_browser(:one) do
      visit legislation_process_proposals_path(process)
      expect(all("[id^='legislation_proposal_']").collect { |e| e[:id] }).to eq(@first_user_proposals_order)
    end

    in_browser(:two) do
      visit legislation_process_proposals_path(process)
      expect(all("[id^='legislation_proposal_']").collect { |e| e[:id] }).to eq(@second_user_proposals_order)
    end
  end
end
