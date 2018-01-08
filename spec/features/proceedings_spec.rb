# coding: utf-8
require 'rails_helper'

feature 'Proceedings' do

  scenario 'creation with sub_proceeding' do
    login_as (create(:user, :level_two))

    visit new_proposal_path(proceeding: "Derechos Humanos", sub_proceeding: "Derecho a una vivienda digna")

    expect(page).to have_content("Derechos Humanos")
    expect(page).to have_content("Derecho a una vivienda digna")

    fill_in :proposal_title, with: "This is the proposal title"
    fill_in :proposal_summary, with: "This is the proposal summary"
    fill_in :proposal_description, with: "This is the proposal description"
    check 'proposal_terms_of_service'

    click_button 'Create proposal'
    click_link 'Not now, go to my proposal'

    expect(page).to have_content("Derechos Humanos")
    expect(page).to have_content("Derecho a una vivienda digna")
    expect(page).to have_content("This is the proposal title")
    expect(page).to have_content("This is the proposal summary")
    expect(page).to have_content("This is the proposal description")
  end

  scenario 'creation without sub_proceeding' do
    login_as (create(:user, :level_two))

    visit new_proposal_path(proceeding: "Derechos Humanos")

    expect(page).to have_content("Derechos Humanos")

    fill_in :proposal_sub_proceeding, with: "Derecho a una buena salud"
    fill_in :proposal_title, with: "This is the proposal title"
    fill_in :proposal_summary, with: "This is the proposal summary"
    fill_in :proposal_description, with: "This is the proposal description"
    check 'proposal_terms_of_service'

    click_button 'Create proposal'
    click_link 'Not now, go to my proposal'

    expect(page).to have_content("Derechos Humanos")
    expect(page).to have_content("Derecho a una buena salud")
    expect(page).to have_content("This is the proposal title")
    expect(page).to have_content("This is the proposal summary")
    expect(page).to have_content("This is the proposal description")

  end

  scenario 'proceeding proposals are not listed in the index' do

    create(:proposal, title: "A test proposal")
    create(:proposal, title: "Another test proposal", proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la intimidad")

    visit proposals_path

    expect(page).to have_content("A test proposal")
    expect(page).not_to have_content("Another test proposal")
  end

end
