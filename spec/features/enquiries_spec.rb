# coding: utf-8
require 'rails_helper'

feature 'Enquiries' do

  context 'Index' do
    scenario 'Lists enquiries from proposals as well as regular enquiries' do
      normal_enquiry = create(:enquiry)
      proposal_enquiry = create(:enquiry, proposal: create(:proposal))

      visit enquiries_path

      expect(proposal_enquiry.title).to appear_before(normal_enquiry.title)
    end

    scenario 'Filtering enquiries' do
      create(:enquiry, title: "Open Enquiry")
      create(:enquiry, :incoming, title: "Incoming Enquiry")
      create(:enquiry, :expired, title: "Expired Enquiry")

      visit enquiries_path
      expect(page).to have_content('Open Enquiry')
      expect(page).to_not have_content('Incoming Enquiry')
      expect(page).to_not have_content('Expired Enquiry')

      visit enquiries_path(filter: 'incoming')
      expect(page).to_not have_content('Open Enquiry')
      expect(page).to have_content('Incoming Enquiry')
      expect(page).to_not have_content('Expired Enquiry')

      visit enquiries_path(filter: 'expired')
      expect(page).to_not have_content('Open Enquiry')
      expect(page).to_not have_content('Incoming Enquiry')
      expect(page).to have_content('Expired Enquiry')
    end

    scenario "Current filter is properly highlighted" do
      visit enquiries_path
      expect(page).to_not have_link('Open')
      expect(page).to have_link('Incoming')
      expect(page).to have_link('Expired')

      visit enquiries_path(filter: 'incoming')
      expect(page).to have_link('Open')
      expect(page).to_not have_link('Incoming')
      expect(page).to have_link('Expired')

      visit enquiries_path(filter: 'expired')
      expect(page).to have_link('Open')
      expect(page).to have_link('Incoming')
      expect(page).to_not have_link('Expired')
    end
  end
end
