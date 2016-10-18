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
    let(:geozone) { create(:geozone) }

    scenario 'Non-logged in users' do
      enquiry = create(:enquiry, valid_answers: 'Han Solo, Chewbacca')
      visit enquiry_path(enquiry)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must Sign in or Sign up to participate')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      enquiry = create(:enquiry, geozone_ids: [geozone.id], valid_answers: 'Han Solo, Chewbacca')
      login_as(create(:user, geozone: geozone))
      visit enquiry_path(enquiry)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must verify your account in order to answer')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 2 users in an incoming enquiry' do
      incoming_enquiry = create(:enquiry, :incoming, geozone_ids: [geozone.id], valid_answers: 'Rey, Finn')
      login_as(create(:user, :level_two, geozone: geozone))

      visit enquiry_path(incoming_enquiry)

      expect(page).to have_content('Rey')
      expect(page).to have_content('Finn')
      expect(page).to_not have_link('Rey')
      expect(page).to_not have_link('Finn')

      expect(page).to have_content('This enquiry has not yet started')
    end

    scenario 'Level 2 users in an expired enquiry' do
      expired_enquiry = create(:enquiry, :expired, geozone_ids: [geozone.id], valid_answers: 'Luke, Leia')
      login_as(create(:user, :level_two, geozone: geozone))

      visit enquiry_path(expired_enquiry)

      expect(page).to have_content('Luke')
      expect(page).to have_content('Leia')
      expect(page).to_not have_link('Luke')
      expect(page).to_not have_link('Leia')

      expect(page).to have_content('This enquiry has finished')
    end

    scenario 'Level 2 users in an enquiry for a geozone which is not theirs' do
      enquiry = create(:enquiry, geozone_ids: [], valid_answers: 'Vader, Palpatine')
      login_as(create(:user, :level_two))

      visit enquiry_path(enquiry)

      expect(page).to have_content('Vader')
      expect(page).to have_content('Palpatine')
      expect(page).to_not have_link('Vader')
      expect(page).to_not have_link('Palpatine')
    end

    scenario 'Level 2 users who can answer' do
      enquiry = create(:enquiry, geozone_ids: [geozone.id], valid_answers: 'Han Solo, Chewbacca')
      login_as(create(:user, :level_two, geozone: geozone))
      visit enquiry_path(enquiry)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users who have already answered' do
      enquiry = create(:enquiry, geozone_ids:[geozone.id], valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)
      create(:enquiry_answer, enquiry: enquiry, author: user, answer: 'Chewbacca')
      login_as user
      visit enquiry_path(enquiry)

      expect(page).to have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
      expect(page).to have_content('Chewbacca')
    end

    scenario 'Level 2 users answering', :js do
      enquiry = create(:enquiry, geozone_ids: [geozone.id], valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)
      login_as user
      visit enquiry_path(enquiry)

      click_link 'Han Solo'

      expect(page).to_not have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

  end

end
