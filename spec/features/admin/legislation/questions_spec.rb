require 'rails_helper'

feature 'Admin legislation questions' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "legislation_question",
                  "edit_admin_legislation_process_question_path",
                  %w[title]

  context "Feature flag" do

    background do
      Setting['feature.legislation'] = nil
    end

    after do
      Setting['feature.legislation'] = true
    end

    scenario 'Disabled with a feature flag' do
      process = create(:legislation_process)
      expect{ visit admin_legislation_process_questions_path(process) }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario 'Displaying legislation process questions' do
      process = create(:legislation_process, title: 'An example legislation process')
      question = create(:legislation_question, process: process, title: 'Question 1')
      question = create(:legislation_question, process: process, title: 'Question 2')

      visit admin_legislation_processes_path(filter: 'all')

      click_link 'An example legislation process'
      click_link 'Debate'

      expect(page).to have_content('Question 1')
      expect(page).to have_content('Question 2')
    end
  end

  context 'Create' do
    scenario 'Valid legislation question' do
      process = create(:legislation_process, title: 'An example legislation process')

      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      expect(page).to have_content 'An example legislation process'

      click_link 'An example legislation process'
      click_link 'Debate'

      click_link 'Create question'

      fill_in 'legislation_question_title_en', with: 'Question 3'
      click_button 'Create question'

      expect(page).to have_content 'Question 3'
    end
  end

  context 'Update' do
    scenario 'Valid legislation question', :js do
      process = create(:legislation_process, title: 'An example legislation process')
      question = create(:legislation_question, title: 'Question 2', process: process)

      visit admin_root_path

      within('#side_menu') do
        click_link "Collaborative Legislation"
      end

      click_link "All"

      expect(page).to have_content 'An example legislation process'

      click_link 'An example legislation process'
      click_link 'Debate'

      click_link 'Question 2'

      fill_in 'legislation_question_title_en', with: 'Question 2b'
      click_button 'Save changes'

      expect(page).to have_content 'Question 2b'
    end
  end

  context 'Delete' do
    scenario 'Legislation question', :js do
      process = create(:legislation_process, title: 'An example legislation process')
      create(:legislation_question, title: 'Question 1', process: process)
      question = create(:legislation_question, title: 'Question 2', process: process)
      question_option = create(:legislation_question_option, question: question, value: 'Yes')
      create(:legislation_answer, question: question, question_option: question_option)

      visit edit_admin_legislation_process_question_path(process, question)

      click_link 'Delete'

      expect(page).to have_content 'Questions'
      expect(page).to have_content 'Question 1'
      expect(page).not_to have_content 'Question 2'
    end
  end

  context "Special translation behaviour" do

    let!(:question) { create(:legislation_question,
                             title_en: "Title in English",
                             title_es: "Título en Español") }

    before do
      @edit_question_url = edit_admin_legislation_process_question_path(question.process, question)
    end

    scenario 'Add translation for question option', :js do
      visit @edit_question_url

      click_on 'Add option'

      find('#nested-question-options input').set('Option 1')

      click_link "Español"

      find('#nested-question-options input').set('Opción 1')

      click_button "Save changes"
      visit @edit_question_url

      expect(page).to have_field('legislation_question_question_options_attributes_0_value_en', with: 'Option 1')

      click_link "Español"

      expect(page).to have_field('legislation_question_question_options_attributes_0_value_es', with: 'Opción 1')
    end

    scenario 'Add new question option after changing active locale', :js do
      visit @edit_question_url

      click_link "Español"

      click_on 'Add option'

      find('#nested-question-options input').set('Opción 1')

      click_link "English"

      find('#nested-question-options input').set('Option 1')

      click_button "Save changes"

      visit @edit_question_url

      expect(page).to have_field('legislation_question_question_options_attributes_0_value_en', with: 'Option 1')

      click_link "Español"

      expect(page).to have_field('legislation_question_question_options_attributes_0_value_es', with: 'Opción 1')
    end
  end
end
