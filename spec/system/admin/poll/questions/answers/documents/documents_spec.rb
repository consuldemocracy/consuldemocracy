require "rails_helper"

describe "Documents" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "Answer with no documents" do
      answer = create(:poll_question_answer, question: create(:poll_question))
      document = create(:document)

      visit admin_answer_documents_path(answer)

      expect(page).not_to have_content(document.title)
    end

    scenario "Answer with documents" do
      answer = create(:poll_question_answer, question: create(:poll_question))
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)

      expect(page).to have_content(document.title)
    end
  end

  scenario "Remove document from answer", :js do
    answer = create(:poll_question_answer, question: create(:poll_question))
    document = create(:document, documentable: answer)

    visit admin_answer_documents_path(answer)
    expect(page).to have_content(document.title)

    accept_confirm "Are you sure?" do
      click_link "Delete"
    end

    expect(page).not_to have_content(document.title)
  end

end
