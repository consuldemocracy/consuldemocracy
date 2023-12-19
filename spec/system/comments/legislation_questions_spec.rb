require "rails_helper"

describe "Commenting legislation questions" do
  let(:user) { create(:user, :level_two) }
  let(:process) { create(:legislation_process, :in_debate_phase) }
  let(:question) { create(:legislation_question, process: process) }

  context "Concerns" do
    it_behaves_like "notifiable in-app", :legislation_question
    it_behaves_like "flaggable", :legislation_question_comment
  end

  scenario "Submit button is disabled after clicking" do
    login_as(user)
    visit legislation_process_question_path(question.process, question)

    fill_in "Leave your answer", with: "Testing submit button!"
    click_button "Publish answer"

    expect(page).to have_button "Publish answer", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish answer", disabled: false
  end
end
