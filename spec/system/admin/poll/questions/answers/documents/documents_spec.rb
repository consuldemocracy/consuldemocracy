require "rails_helper"

describe "Documents", :admin do
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

  scenario "Create document for answer" do
    answer = create(:poll_question_answer)

    visit admin_answer_documents_path(answer)

    documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
    click_button "Save"

    expect(page).to have_content "Document uploaded succesfully"
    expect(page).to have_link "clippy.pdf"
  end

  scenario "Remove document from answer" do
    answer = create(:poll_question_answer)
    document = create(:document, documentable: answer)

    visit admin_answer_documents_path(answer)
    expect(page).to have_content(document.title)

    accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
      click_button "Delete"
    end

    expect(page).not_to have_content(document.title)
  end
end
