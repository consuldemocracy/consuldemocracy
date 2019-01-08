require 'rails_helper'

feature 'Residence', :with_frozen_time do
  let(:officer) { create(:poll_officer) }

  feature "Officers without assignments" do

    scenario "Can not access residence verification" do
      login_as(officer.user)
      visit officing_root_path

      expect(page).not_to have_link("Validate document")
      expect(page).to have_content("You don't have officing shifts today")

      create(:poll_officer_assignment, officer: officer, date: 1.day.from_now)

      visit new_officing_residence_path

      expect(page).to have_content("You don't have officing shifts today")
    end

  end

  feature "Assigned officers" do

    background do
      create(:poll_officer_assignment, officer: officer)
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

      within("#new_residence") do
        click_button "Validate document"
      end

      expect(page).to have_content(/\d errors? prevented the verification of this document/)
    end

    scenario "Error on Census (document number)" do
      initial_failed_census_calls_count = officer.failed_census_calls_count
      within("#side_menu") do
        click_link "Validate document"
      end

      select 'DNI', from: 'residence_document_type'
      fill_in 'residence_document_number', with: "9999999A"
      fill_in 'residence_year_of_birth', with: '1980'

      click_button 'Validate document'

      expect(page).to have_content 'The Census was unable to verify this document'

      officer.reload
      fcc = FailedCensusCall.last
      expect(fcc).to be
      expect(fcc.poll_officer).to eq(officer)
      expect(officer.failed_census_calls.last).to eq(fcc)
      expect(officer.failed_census_calls_count).to eq(initial_failed_census_calls_count + 1)
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

end
