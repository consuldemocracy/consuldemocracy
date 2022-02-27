require "rails_helper"

describe "Documents", :admin do
  let(:future_poll) { create(:poll) }
  let(:current_poll) { create(:poll, :current) }

  context "Index" do
    scenario "Answer with no documents" do
      answer = create(:poll_question_answer)
      document = create(:document)

      visit admin_answer_documents_path(answer)

      expect(page).not_to have_content(document.title)
    end

    scenario "Answer with documents" do
      answer = create(:poll_question_answer)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)

      expect(page).to have_content(document.title)
    end
  end

  context "Add document to answer" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Documents list"
      end

      expect(page).not_to have_content("clippy.jpg")

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
      click_button "Save"

      expect(page).to have_content "Changes saved"

      within("#poll_question_answer_#{answer.id}") do
        click_link "Documents list"
      end

      expect(page).to have_link "clippy.pdf"
      expect(answer.documents).not_to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_answer_documents_path(answer)
      expect(page).not_to have_content("clippy.jpg")

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.jpg"))
      click_button "Save"

      expect(page).to have_content "It is not possible to modify answers for an already started poll."

      expect(answer.images).to be_empty
    end
  end

  context "Remove document from answer" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)
      expect(page).to have_content(document.title)

      accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
        click_button "Delete"
      end

      expect(page).to have_content "Document was deleted successfully."
      expect(page).not_to have_content(document.title)

      expect(answer.documents).to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)
      expect(page).to have_content(document.title)

      accept_confirm { click_button "Delete" }

      expect(page).to have_content "It is not possible to modify answers for an already started poll."
      visit admin_answer_documents_path(answer)
      expect(page).to have_content(document.title)

      expect(answer.documents).not_to be_empty
    end
  end
end
