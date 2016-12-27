require 'rails_helper'

feature 'Legislation' do

  context 'process debate page' do
    scenario 'shows question list' do
      process = create(:legislation_process, debate_start_date: Date.current - 1.day, debate_end_date: Date.current + 2.days)
      create(:legislation_question, process: process, title: "Question 1")
      create(:legislation_question, process: process, title: "Question 2")
      create(:legislation_question, process: process, title: "Question 3")

      visit legislation_process_path(process)

      expect(page).to have_content("Participate in the debate")

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Question 2")
      expect(page).to have_content("Question 3")

      click_link "Question 1"

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 2")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 3")
      expect(page).to_not have_content("Next question")
    end
  end
end
