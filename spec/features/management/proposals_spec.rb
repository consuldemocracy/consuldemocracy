require 'rails_helper'

feature 'Proposals' do

  scenario 'Creating proposals on behalve of someone' do
    ####CHANGE ME
    ####Should identify the user being managed
    managed_user = create(:user)
    ####

    manager = create(:manager)
    visit management_sign_in_path(login: manager.username, clave_usuario: manager.password)

    visit new_management_proposal_path

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'http://youtube.com'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    fill_in 'proposal_captcha', with: correct_captcha_text
    check 'proposal_terms_of_service'

    click_button 'Start a proposal'

    expect(page).to have_content 'Proposal was successfully created.'

    expect(page).to have_content 'Help refugees'
    expect(page).to have_content '¿Would you like to give assistance to war refugees?'
    expect(page).to have_content 'In summary, what we want is...'
    expect(page).to have_content 'This is very important because...'
    expect(page).to have_content 'http://rescue.org/refugees'
    expect(page).to have_content 'http://youtube.com'
    expect(page).to have_content managed_user.name
    expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)
  end

  scenario 'Voting proposals on behalve of someone'
  scenario 'Printing proposals'

end