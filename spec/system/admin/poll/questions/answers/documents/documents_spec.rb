require "rails_helper"

describe "Documents", :admin do
  let(:future_poll) { create(:poll, :future) }

  context "Index" do
    scenario "Answer with no documents" do
      answer = create(:poll_question_answer)
      document = create(:document)

      visit admin_answer_documents_path(answer)

      expect(page).not_to have_content(document.title)
      expect(page).to have_link "Go back", href: admin_question_path(answer.question)
    end

    scenario "Answer with documents" do
      answer = create(:poll_question_answer)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)

      expect(page).to have_content(document.title)
    end
  end

  describe "Create document for answer" do
    scenario "with valid data" do
      answer = create(:poll_question_answer, poll: future_poll)

      visit admin_answer_documents_path(answer)

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
      click_button "Save"

      expect(page).to have_content "Document uploaded successfully"
      expect(page).to have_link "clippy.pdf"
    end

    scenario "with invalid data" do
      answer = create(:poll_question_answer, poll: future_poll)

      visit admin_answer_documents_path(answer)

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
      fill_in "Title", with: ""
      click_button "Save"

      expect(page).to have_content "1 error prevented this Answer from being saved"
      expect(page).to have_content "Documents list"
    end
  end

  scenario "Remove document from answer" do
    answer = create(:poll_question_answer, poll: future_poll)
    document = create(:document, documentable: answer)

    visit admin_answer_documents_path(answer)
    expect(page).to have_content(document.title)

    accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
      click_button "Delete"
    end

    expect(page).to have_content "Document was deleted successfully."
    expect(page).not_to have_content(document.title)
  end
end
