require 'rails_helper'

feature 'Legislation' do

  context 'processes#index' do

    scenario 'Processes can be listed' do
      processes = create_list(:legislation_process, 3)

      visit legislation_processes_path

      processes.each do |process|
        expect(page).to have_link(process.title)
      end
    end

    scenario 'Filtering processes' do
      create(:legislation_process, title: "Process open")
      create(:legislation_process, :next, title: "Process next")
      create(:legislation_process, :past, title: "Process past")

      visit legislation_processes_path
      expect(page).to have_content('Process open')
      expect(page).to_not have_content('Process next')
      expect(page).to_not have_content('Process past')

      visit legislation_processes_path(filter: 'next')
      expect(page).to_not have_content('Process open')
      expect(page).to have_content('Process next')
      expect(page).to_not have_content('Process past')

      visit legislation_processes_path(filter: 'past')
      expect(page).to_not have_content('Process open')
      expect(page).to_not have_content('Process next')
      expect(page).to have_content('Process past')
    end
  end
end
