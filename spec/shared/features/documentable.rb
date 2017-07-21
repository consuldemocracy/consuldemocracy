shared_examples "documentable" do |documentable_factory_name, documentable_path, documentable_path_arguments|
  include ActionView::Helpers

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }
  let!(:documentable_dom_name)  { documentable_factory_name.gsub('_', '-') }

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  context "Show" do

    scenario "Should not display upload document button when there is no logged user" do
      visit send(documentable_path, arguments)

      within "##{dom_id(documentable)}" do
        expect(page).not_to have_link("Upload document")
      end
    end

    scenario "Should display upload document button when user is logged in and is documentable owner" do
      login_as(user)

      visit send(documentable_path, arguments)

      within "##{dom_id(documentable)}" do
        expect(page).to have_link("Upload document")
      end
    end

    scenario "Should display upload document button when admin is logged in" do
      login_as(administrator)

      visit send(documentable_path, arguments)

      within "##{dom_id(documentable)}" do
        expect(page).to have_link("Upload document")
      end
    end

    scenario "Should navigate to new document page when click un upload button" do
      login_as(user)

      visit send(documentable_path, arguments)
      click_link  "Upload document"

      expect(page).to have_selector("h1", text: "Upload document")
    end

    describe "Documents tab" do

      let!(:document) { create(:document, documentable: documentable, user: documentable.author)}

      describe "Download action" do

        scenario "Should be able to anyone" do
          visit send(documentable_path, arguments)

          within "#tab-documents" do
            expect(page).to have_link("Download")
          end
        end

      end

      describe "Destroy action" do

        scenario "Should not be able when no user logged in" do
          visit send(documentable_path, arguments)

          within "#tab-documents" do
            expect(page).not_to have_link("Destroy")
          end
        end

        scenario "Should be able when documentable author is logged in" do
          login_as documentable.author
          visit send(documentable_path, arguments)

          within "#tab-documents" do
            expect(page).to have_link("Destroy")
          end
        end

        scenario "Should be able when any administrator logged in" do
          login_as administrator
          visit send(documentable_path, arguments)

          within "#tab-documents" do
            expect(page).to have_link("Destroy")
          end
        end

      end

    end

  end

  context "New" do

    scenario "Should not be able for unathenticated users" do
      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id)

      expect(page).to have_content("You must sign in or register to continue.")
    end

    scenario "Should not be able for other users" do
      login_as create(:user)

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id)

      expect(page).to have_content("You do not have permission to carry out the action 'new' on document. ")
    end

    scenario "Should be able to documentable author" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id)

      expect(page).to have_selector("h1", text: "Upload document")
    end

  end

  context "Create" do

    scenario "Should show validation errors" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id)
      click_on "Upload document"

      expect(page).to have_content "2 errors prevented this Document from being saved: "
      expect(page).to have_selector "small.error:not(.show-for-sr)", text: "can't be blank", count: 2
      expect(page).to have_selector "small.show-for-sr", text: "can't be blank", count: 1
    end

    scenario "Should display file name after file selection", :js do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id)
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"

      expect(page).to have_content "empty.pdf"
    end

    scenario "Should show error notice after unsuccessfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id, from: send(documentable_path, arguments))
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_content "Cannot create document. Check form errors and try again."
    end

    scenario "Should show success notice after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id, from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_content "Document was created successfully."
    end

    scenario "Should redirect to documentable path after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id, from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      within "##{dom_id(documentable)}" do
        expect(page).to have_selector "h1", text: documentable.title
      end
    end

    scenario "Should show new document on documentable documents tab after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name, documentable_id: documentable.id, from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_link "Documents (1)"
      within "#tab-documents" do
        within "#document_#{Document.last.id}" do
          expect(page).to have_content "Document title"
          expect(page).to have_link "Download"
          expect(page).to have_link "Destroy"
        end
      end
    end

  end

  context "Destroy" do

    let!(:document) { create(:document, documentable: documentable, user: documentable.author) }

    scenario "Should show success notice after successfull document upload" do
      login_as documentable.author

      visit send(documentable_path, arguments)
      within "#tab-documents" do
        within "#document_#{document.id}" do
          click_on "Destroy"
        end
      end

      expect(page).to have_content "Document was deleted successfully."
    end

    scenario "Should update documents tab count after successful deletion" do
      login_as documentable.author

      visit send(documentable_path, arguments)
      within "#tab-documents" do
        within "#document_#{document.id}" do
          click_on "Destroy"
        end
      end

      expect(page).to have_link "Documents (0)"
    end

    scenario "Should redirect to documentable path after successful deletion" do
      login_as documentable.author

      visit send(documentable_path, arguments)
      within "#tab-documents" do
        within "#document_#{document.id}" do
          click_on "Destroy"
        end
      end

      within "##{dom_id(documentable)}" do
        expect(page).to have_selector "h1", text: documentable.title
      end
    end

  end

end
