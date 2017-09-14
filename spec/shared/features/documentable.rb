shared_examples "documentable" do |documentable_factory_name, documentable_path, documentable_path_arguments|
  include ActionView::Helpers
  include DocumentsHelper
  include DocumentablesHelper

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }
  let!(:documentable_dom_name)  { documentable_factory_name.parameterize }

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

    scenario "Should not display upload document button when maximum number of documents reached " do
      create_list(:document, 3, documentable: documentable)
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
      click_link "Upload document"

      expect(page).to have_selector("h1", text: "Upload document")
    end

    describe "Documents tab" do

      let!(:document) { create(:document, documentable: documentable, user: documentable.author)}

      scenario "Should not display maximum number of documents alert when reached for users without document creation permission" do
        create_list(:document, 2, documentable: documentable)
        visit send(documentable_path, arguments)

        within "#tab-documents" do
          expect(page).not_to have_content "You have reached the maximum number of documents allowed! You have to delete one before you can upload another."
        end
      end

      scenario "Should display maximum number of documents alert when reached and when current user has document creation permission" do
        login_as documentable.author
        create_list(:document, 2, documentable: documentable)
        visit send(documentable_path, arguments)

        within "#tab-documents" do
          expect(page).to have_content "You have reached the maximum number of documents allowed! You have to delete one before you can upload another."
        end
      end

      scenario "Download action should be able to anyone" do
        visit send(documentable_path, arguments)

        within "#tab-documents" do
          expect(page).to have_link("Dowload file")
        end
      end

      scenario "Download file link should have blank target attribute" do
        visit send(documentable_path, arguments)

        within "#tab-documents" do
          expect(page).to have_selector("a[target=_blank]", text: "Dowload file")
        end
      end

      scenario "Download file links should have rel attribute setted to no follow" do
        visit send(documentable_path, arguments)

        within "#tab-documents" do
          expect(page).to have_selector("a[rel=nofollow]", text: "Dowload file")
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
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      expect(page).to have_content("You must sign in or register to continue.")
    end

    scenario "Should not be able for other users" do
      login_as create(:user)

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      expect(page).to have_content("You do not have permission to carry out the action 'new' on document. ")
    end

    scenario "Should be able to documentable author" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      expect(page).to have_selector("h1", text: "Upload document")
    end

    scenario "Should display file name after file selection", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_file :document_attachment, "spec/fixtures/files/empty.pdf", make_visible: true

      expect(page).to have_content "empty.pdf"
    end

    scenario "Should not display file name after file selection", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/logo_header.png", false)

      expect(page).not_to have_content "logo_header.jpg"
    end

    scenario "Should update loading bar style after valid file upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/empty.pdf", true)

      expect(page).to have_selector ".loading-bar.complete"
    end

    scenario "Should update loading bar style after unvalid file upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/logo_header.png", false)

      expect(page).to have_selector ".loading-bar.errors"
    end

    scenario "Should update document title with attachment original file name after file selection if no title defined by user", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/empty.pdf", true)

      expect(page).to have_css("input[name='document[title]'][value='empty.pdf']")
    end

    scenario "Should not update document title with attachment original file name after file selection when title already defined by user", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      fill_in :document_title, with: "My custom title"
      attach_document("spec/fixtures/files/empty.pdf", true)

      expect(find("input[name='document[title]']").value).to eq("My custom title")
    end

    scenario "Should update document cached_attachment field after valid file upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/empty.pdf", true)

      expect(page).to have_css("input[name='document[cached_attachment]'][value$='empty.pdf']", visible: false)
    end

    scenario "Should not show 'Choose document' button after valid upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_file :document_attachment, "spec/fixtures/files/empty.pdf", make_visible: true
      sleep 1

      expect(page).not_to have_content "Choose document"
    end

    scenario "Should show 'Remove document' button after valid upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_file :document_attachment, "spec/fixtures/files/empty.pdf", make_visible: true
      sleep 1

      expect(page).to have_link("Remove document")
    end

    scenario "Should show 'Choose document' button after remove valid upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_file :document_attachment, "spec/fixtures/files/empty.pdf", make_visible: true
      sleep 1
      click_link "Remove document"
      sleep 1

      expect(page).to have_content "Choose document"
    end

    scenario "Should not update document cached_attachment field after unvalid file upload", :js do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      attach_document("spec/fixtures/files/logo_header.png", false)

      expect(find("input[name='document[cached_attachment]']", visible: false).value).to eq("")
    end

    scenario "Should show documentable custom recomentations" do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id,
                              from: send(documentable_path, arguments))

      expect(page).to have_content "You can upload up to a maximum of #{max_file_size(documentable)} documents."
      expect(page).to have_content "You can upload #{documentable_humanized_accepted_content_types(documentable)} files."
      expect(page).to have_content "You can upload files up to #{max_file_size(documentable)} MB."
    end

  end

  context "Create" do

    scenario "Should show validation errors" do
      login_as documentable.author
      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id)

      click_on "Upload document"

      expect(page).to have_content "2 errors prevented this Document from being saved: "
      expect(page).to have_selector "small.error", text: "can't be blank", count: 2
    end

    scenario "Should show error notice after unsuccessfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id,
                              from: send(documentable_path, arguments))
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_content "Cannot create document. Check form errors and try again."
    end

    scenario "Should show success notice after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id,
                              from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_content "Document was created successfully."
    end

    scenario "Should redirect to documentable path after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id,
                              from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      within "##{dom_id(documentable)}" do
        expect(page).to have_selector "h1", text: documentable.title
      end
    end

    scenario "Should show new document on documentable documents tab after successfull document upload" do
      login_as documentable.author

      visit new_document_path(documentable_type: documentable.class.name,
                              documentable_id: documentable.id,
                              from: send(documentable_path, arguments))
      fill_in :document_title, with: "Document title"
      attach_file :document_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload document"

      expect(page).to have_link "Documents (1)"
      within "#tab-documents" do
        within "#document_#{Document.last.id}" do
          expect(page).to have_content "Document title"
          expect(page).to have_link "Dowload file"
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

def attach_document(path, success = true)
  attach_file :document_attachment, path, make_visible: true
  if success
    have_css ".loading-bar.complete"
  else
    have_css ".loading-bar.errors"
  end
end