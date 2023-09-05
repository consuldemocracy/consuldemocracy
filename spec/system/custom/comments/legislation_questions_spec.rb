require "rails_helper"

describe "Commenting legislation questions" do
  let(:user) { create :user, :level_two }
  let(:process) { create :legislation_process, :in_debate_phase }
  let(:legislation_question) { create :legislation_question, process: process }

  scenario "Show order links only if there are comments" do
    visit legislation_process_question_path(legislation_question.process, legislation_question)

    within "#comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: legislation_question, user: user)
    visit legislation_process_question_path(legislation_question.process, legislation_question)

    within "#comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
