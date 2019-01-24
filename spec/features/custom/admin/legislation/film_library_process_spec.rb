require 'rails_helper'

feature 'Admin legislation processes' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context 'Create' do
    scenario 'Valid filmoteca legislation process' do
      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      expect(page).not_to have_content 'Filmoteca process'

      click_link "New process"

      fill_in 'Process Title', with: 'Filmoteca process'
      fill_in 'Summary', with: 'Summary of the filmoteca process'
      fill_in 'Description', with: 'Describing the filmoteca process'

      base_date = Date.current
      fill_in 'legislation_process[start_date]', with: base_date.strftime("%d/%m/%Y")
      fill_in 'legislation_process[end_date]', with: (base_date + 5.days).strftime("%d/%m/%Y")

      check 'legislation_process_film_library'

      click_button 'Create process'

      expect(page).to have_content 'Filmoteca process'
      expect(page).to have_content 'Process created successfully'
      expect(page).to have_field('legislation_process_film_library', checked: true)

      click_link 'Click to visit'

      expect(page).to have_content 'Filmoteca process'
      expect(page).not_to have_content 'Summary of the filmoteca process'
      expect(page).to have_content 'Describing the filmoteca process'

      visit legislation_processes_path

      expect(page).not_to have_content 'Filmoteca process'
      expect(page).not_to have_content 'Summary of the filmoteca process'
      expect(page).not_to have_content 'Describing the filmoteca process'
    end
  end
end
