require 'rails_helper'

feature 'Residence' do
  let(:officer) { create(:poll_officer) }

  background do
    login_as(officer.user)
    visit officing_root_path
  end

  scenario "Verify voter" do
    within("#side_menu") do
      click_link "Validate document"
    end

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_year_of_birth', with: '1980'

    click_button 'Validate document'

    expect(page).to have_content 'Document verified with Census'
  end

  scenario "Error on verify" do
    within("#side_menu") do
      click_link "Validate document"
    end

    click_button 'Validate document'
    expect(page).to have_content /\d errors? prevented the verification of this document/
  end

  scenario "Error on Census (document number)" do
    within("#side_menu") do
      click_link "Validate document"
    end

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "9999999A"
    fill_in 'residence_year_of_birth', with: '1980'

    click_button 'Validate document'

    expect(page).to have_content 'The Census was unable to verify this document'
  end

  scenario "Error on Census (year of birth)" do
    within("#side_menu") do
      click_link "Validate document"
    end

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_year_of_birth', with: '1981'

    click_button 'Validate document'

    expect(page).to have_content 'The Census was unable to verify this document'
  end

end