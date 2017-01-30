require 'rails_helper'

feature 'Legislation' do

  context 'processes home page' do

    scenario 'Processes can be listed' do
      visit legislation_processes_path
      expect(page).to have_text "There aren't open processes"

      visit legislation_processes_path(filter: 'next')
      expect(page).to have_text "There aren't planned processes"

      visit legislation_processes_path(filter: 'past')
      expect(page).to have_text "There aren't past processes"
    end

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

  context 'process page' do
    context 'debate phase' do
      scenario 'not open' do
        process = create(:legislation_process, debate_start_date: Date.current + 1.day, debate_end_date: Date.current + 2.days)

        visit legislation_process_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, debate_start_date: Date.current - 1.day, debate_end_date: Date.current + 2.days)

        visit legislation_process_path(process)

        expect(page).to have_content("Participate in the debate")
      end
    end

    context 'draft publication phase' do
      scenario 'not open' do
        process = create(:legislation_process, draft_publication_date: Date.current + 1.day)

        visit legislation_process_draft_publication_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, draft_publication_date: Date.current)

        visit legislation_process_draft_publication_path(process)

        expect(page).to have_content("Nothing published yet")
      end
    end

    context 'allegations phase' do
      scenario 'not open' do
        process = create(:legislation_process, allegations_start_date: Date.current + 1.day, allegations_end_date: Date.current + 2.days)

        visit legislation_process_allegations_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, allegations_start_date: Date.current - 1.day, allegations_end_date: Date.current + 2.days)

        visit legislation_process_allegations_path(process)

        expect(page).to have_content("Nothing published yet")
      end
    end

    context 'final version publication phase' do
      scenario 'not open' do
        process = create(:legislation_process, final_publication_date: Date.current + 1.day)

        visit legislation_process_final_version_publication_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, final_publication_date: Date.current)

        visit legislation_process_final_version_publication_path(process)

        expect(page).to have_content("Nothing published yet")
      end
    end
  end
end
