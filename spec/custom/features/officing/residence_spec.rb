require 'rails_helper'

feature 'Residence' do
  let(:officer) { create(:poll_officer) }



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
      fill_in 'residence_year_of_birth', with: "#{valid_date_of_birth_year}"

      click_button 'Validate document'

      expect(page).to have_content 'Document verified with Census'
    end

  end

end
