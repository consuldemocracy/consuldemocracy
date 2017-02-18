require 'rails_helper'

feature 'Letters' do
  let(:officer) { create(:poll_officer) }

  background do
    login_as(officer.user)
    visit new_envelope_path
  end

  scenario "Verify voter" do
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'Document verified with Census'
  end

  scenario "Error on verify" do
    click_button 'Validate document'
    expect(page).to have_content(/\d errors? prevented the verification of this document/)
  end

  scenario "Error on Census (document number)" do
    initial_failed_census_calls_count = officer.failed_census_calls_count
    visit new_envelope_path

    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "9999999A"
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Validate document'

    expect(page).to have_content 'The Census was unable to verify this document'

    officer.reload
    fcc = FailedCensusCall.last
    expect(fcc).to be
    expect(fcc.poll_officer).to eq(officer)
    expect(officer.failed_census_calls.last).to eq(fcc)
    expect(officer.failed_census_calls_count).to eq(initial_failed_census_calls_count + 1)
  end

  scenario "Error on Census (postal code)" do
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_postal_code', with: '28014'

    click_button 'Validate document'

    expect(page).to have_content 'The Census was unable to verify this document'
  end

end