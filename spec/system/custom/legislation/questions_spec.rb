require "rails_helper"

describe "Legislation" do
  context "process debate page" do
    let(:process)  { create(:legislation_process) }
    let(:question) { create(:legislation_question, process: process) }

    scenario "do not show next question link with only one question" do
      visit legislation_process_question_path(process, question)

      expect(page).to have_content(question.title)
      expect(page).not_to have_link("Next question")
    end
  end
end
