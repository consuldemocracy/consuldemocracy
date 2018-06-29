# coding: utf-8
require 'rails_helper'

feature 'Proposals' do

  background do
    Setting['feature.map'] = nil
  end

  after do
    Setting['feature.map'] = nil
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in 'proposal_title', with: 'Testing an attack'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: '<p>This is <script>alert("an attack");</script></p>'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'
    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(page).to have_content 'Testing an attack'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).not_to include '<script>alert("an attack");</script>'
    expect(page.html).not_to include '&lt;p&gt;This is'
  end

  # custom tests CDJ Aude -----------------------

  context 'with with cdj_aude feature' do

    before do
      Setting['feature.cdj_aude'] = true
    end

    after do
      Setting['feature.cdj_aude'] = nil
    end

    scenario 'Create ' do
      author = create(:user)
      login_as(author)

      visit new_proposal_path
      expect(page).not_to have_current_path(new_proposal_path)
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "You do not have permission to carry out the action"
    end
  end

  scenario 'Create with verified user without document_number' do
    author = create(:user, :verified)
    login_as(author)

    visit new_proposal_path
    expect(page).to have_selector('#proposal_responsible_name')

    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
    fill_in 'proposal_summary', with: 'In summary, what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    check 'proposal_terms_of_service'

    click_button 'Create proposal'
    expect(page).to have_content 'Proposal created successfully.'

    click_link 'Not now, go to my proposal'

    expect(Proposal.last.responsible_name).to eq(author.name)
  end

end
