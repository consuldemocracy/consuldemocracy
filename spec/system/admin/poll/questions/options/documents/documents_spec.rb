require "rails_helper"

describe "Documents", :admin do
  let(:future_poll) { create(:poll, :future) }

  context "Index" do
    scenario "Option with no documents" do
      option = create(:poll_question_option)
      document = create(:document)

      visit admin_option_documents_path(option)

      expect(page).not_to have_content(document.title)
      expect(page).to have_link "Go back", href: admin_question_path(option.question)
    end

    scenario "Option with documents" do
      option = create(:poll_question_option)
      document = create(:document, documentable: option)

      visit admin_option_documents_path(option)

      expect(page).to have_content(document.title)
    end
  end

  describe "Create document for option" do
    scenario "with valid data" do
      option = create(:poll_question_option, poll: future_poll)

      visit admin_option_documents_path(option)

      expect(page).not_to have_link "Download file"

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
      click_button "Save"

      expect(page).to have_content "Document uploaded successfully"

      within("tr", text: "clippy.pdf") do
        expect(page).to have_link "Download file"
      end
    end

    scenario "with invalid data" do
      option = create(:poll_question_option, poll: future_poll)

      visit admin_option_documents_path(option)

      documentable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.pdf"))
      fill_in "Title", with: ""
      click_button "Save"

      expect(page).to have_content "1 error prevented this Answer from being saved"
      expect(page).to have_content "Documents list"
    end
  end

  scenario "Remove document from option" do
    option = create(:poll_question_option, poll: future_poll)
    document = create(:document, documentable: option)

    visit admin_option_documents_path(option)
    expect(page).to have_content(document.title)

    accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
      click_button "Delete"
    end

    expect(page).to have_content "Document was deleted successfully."
    expect(page).not_to have_content(document.title)
  end
end
