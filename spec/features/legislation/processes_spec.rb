require 'rails_helper'

feature 'Legislation' do

  let!(:administrator) { create(:administrator).user }

  shared_examples "not published permissions" do |path|

    let(:not_published_process) { create(:legislation_process, :not_published, title: "Process not published") }
    let!(:not_permission_message) { "You do not have permission to carry out the action" }

    it "is forbidden for a normal user" do
      visit send(path, not_published_process)

      expect(page).to have_content not_permission_message
      expect(page).not_to have_content("Process not published")
    end

    it "is available for an administrator user" do
      login_as(administrator)
      visit send(path, not_published_process)

      expect(page).to have_content("Process not published")
    end
  end

  context 'processes home page' do

    scenario 'No processes to be listed' do
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
      expect(page).not_to have_content('Process next')
      expect(page).not_to have_content('Process past')

      visit legislation_processes_path(filter: 'next')
      expect(page).not_to have_content('Process open')
      expect(page).to have_content('Process next')
      expect(page).not_to have_content('Process past')

      visit legislation_processes_path(filter: 'past')
      expect(page).not_to have_content('Process open')
      expect(page).not_to have_content('Process next')
      expect(page).to have_content('Process past')
    end

    context "not published processes" do
      before do
        create(:legislation_process, title: "published")
        create(:legislation_process, :not_published, title: "not published")
        [:next, :past].each do |trait|
          create(:legislation_process, trait, title: "#{trait} published")
          create(:legislation_process, :not_published, trait, title: "#{trait} not published")
        end
      end

      it "aren't listed" do
        visit legislation_processes_path
        expect(page).not_to have_content('not published')
        expect(page).to have_content('published')

        login_as(administrator)
        visit legislation_processes_path
        expect(page).not_to have_content('not published')
        expect(page).to have_content('published')
      end

      it "aren't listed with next filter" do
        visit legislation_processes_path(filter: 'next')
        expect(page).not_to have_content('not published')
        expect(page).to have_content('next published')

        login_as(administrator)
        visit legislation_processes_path(filter: 'next')
        expect(page).not_to have_content('not published')
        expect(page).to have_content('next published')
      end

      it "aren't listed with past filter" do
        visit legislation_processes_path(filter: 'past')
        expect(page).not_to have_content('not published')
        expect(page).to have_content('past published')

        login_as(administrator)
        visit legislation_processes_path(filter: 'past')
        expect(page).not_to have_content('not published')
        expect(page).to have_content('past published')
      end
    end
  end

  context 'process page' do
    context "show" do
      include_examples "not published permissions", :legislation_process_path

      scenario '#show view has document present' do
        process = create(:legislation_process)
        document = create(:document, documentable: process)
        visit legislation_process_path(process)

        expect(page).to have_content(document.title)
      end

      scenario 'show additional info button' do
        process = create(:legislation_process, additional_info: "Text for additional info of the process")

        visit legislation_process_path(process)

        expect(page).to have_content("Additional information")
        expect(page).to have_content("Text for additional info of the process")
      end

      scenario 'do not show additional info button if it is empty' do
        process = create(:legislation_process)

        visit legislation_process_path(process)

        expect(page).to_not have_content("Additional information")
      end
    end

    context 'debate phase' do
      scenario 'not open' do
        process = create(:legislation_process, debate_start_date: Date.current + 1.day, debate_end_date: Date.current + 2.days)

        visit legislation_process_path(process)

        expect(page).to     have_content("This phase is not open yet")
        expect(page).to_not have_content("Participate in the debate")
      end

      scenario 'open without questions' do
        process = create(:legislation_process, debate_start_date: Date.current - 1.day, debate_end_date: Date.current + 2.days)

        visit legislation_process_path(process)

        expect(page).to_not have_content("Participate in the debate")
        expect(page).to_not have_content("This phase is not open yet")
      end

      scenario 'open with questions' do
        process = create(:legislation_process, debate_start_date: Date.current - 1.day, debate_end_date: Date.current + 2.days)
        create(:legislation_question, process: process, title: "Question 1")
        create(:legislation_question, process: process, title: "Question 2")

        visit legislation_process_path(process)

        expect(page).to     have_content("Question 1")
        expect(page).to     have_content("Question 2")
        expect(page).to     have_content("Participate in the debate")
        expect(page).to_not have_content("This phase is not open yet")
      end

      include_examples "not published permissions", :debate_legislation_process_path
    end

    context 'draft publication phase' do
      scenario 'not open' do
        process = create(:legislation_process, draft_publication_date: Date.current + 1.day)

        visit draft_publication_legislation_process_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, draft_publication_date: Date.current)

        visit draft_publication_legislation_process_path(process)

        expect(page).to have_content("Nothing published yet")
      end

      include_examples "not published permissions", :draft_publication_legislation_process_path
    end

    context 'allegations phase' do
      scenario 'not open' do
        process = create(:legislation_process, allegations_start_date: Date.current + 1.day, allegations_end_date: Date.current + 2.days)

        visit allegations_legislation_process_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, allegations_start_date: Date.current - 1.day, allegations_end_date: Date.current + 2.days)

        visit allegations_legislation_process_path(process)

        expect(page).to have_content("Nothing published yet")
      end

      include_examples "not published permissions", :allegations_legislation_process_path
    end

    context 'final version publication phase' do
      scenario 'not open' do
        process = create(:legislation_process, result_publication_date: Date.current + 1.day)

        visit result_publication_legislation_process_path(process)

        expect(page).to have_content("This phase is not open yet")
      end

      scenario 'open' do
        process = create(:legislation_process, result_publication_date: Date.current)

        visit result_publication_legislation_process_path(process)

        expect(page).to have_content("Nothing published yet")
      end

      include_examples "not published permissions", :result_publication_legislation_process_path
    end
  end
end
