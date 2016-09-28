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

  context 'Answering' do
    background do
      @enquiry = create(:enquiry, valid_answers: 'Han Solo, Chewbacca')
    end

    scenario 'Non-logged in users' do
      visit enquiry_path(@enquiry)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must log in in order to vote')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      login_as(create(:user))
      visit enquiry_path(@enquiry)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must verify your account in order to vote')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    xscenario 'Level 2 users in an incoming enquiry'
    xscenario 'Level 2 users in an expired enquiry'
    xscenario 'Level 2 users in an enquiry for a geozone which is not theirs'

    scenario 'Level 2 users who can answer' do
      login_as(create(:user, :level_two))
      visit enquiry_path(@enquiry)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users who have already answered' do
      user = create(:user, :level_two)
      create(:enquiry_answer, enquiry: @enquiry, author: user, answer: 'Chewbacca')
      login_as user
      visit enquiry_path(@enquiry)

      expect(page).to have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
      expect(page).to have_content('Chewbacca')
    end

    scenario 'Level 2 users answering', :js do
      user = create(:user, :level_two)
      login_as user
      visit enquiry_path(@enquiry)

      click_link 'Han Solo'

      expect(page).to_not have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

  end

end
