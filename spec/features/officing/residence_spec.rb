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

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'

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

  scenario "Error on Census" do
    within("#side_menu") do
      click_link "Validate document"
    end

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select '1997', from: 'residence_date_of_birth_1i'
    select 'January', from: 'residence_date_of_birth_2i'
    select '1', from: 'residence_date_of_birth_3i'

    click_button 'Validate document'

    expect(page).to have_content 'The Census was unable to verify this document'
  end

end