require "rails_helper"

describe "Answers" do
  let(:question) { create(:poll_question) }
  let(:admin) { create(:administrator) }

  before do
    login_as(admin.user)
  end

  scenario "Index" do
    answer1 = create(:poll_question_answer, question: question, given_order: 2)
    answer2 = create(:poll_question_answer, question: question, given_order: 1)

    visit admin_question_path(question)

    expect(page).to have_css(".poll_question_answer", count: 2)
    expect(answer2.title).to appear_before(answer1.title)

    within("#poll_question_answer_#{answer1.id}") do
      expect(page).to have_content answer1.title
      expect(page).to have_content answer1.description
    end
  end

  scenario "Create" do
    visit admin_question_path(question)

    click_link "Add answer"
    fill_in "Answer", with: "¿Would you like to reform Central Park?"
    fill_in "Description", with: "Adding more trees, creating a play area..."
    click_button "Save"

    expect(page).to have_content "Answer created successfully"
    expect(page).to have_css(".poll_question_answer", count: 1)
    expect(page).to have_content "¿Would you like to reform Central Park?"
    expect(page).to have_content "Adding more trees, creating a play area..."
  end

  pending "Update"
  pending "Destroy"

end
