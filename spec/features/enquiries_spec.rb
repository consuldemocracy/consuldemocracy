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
  end
end
