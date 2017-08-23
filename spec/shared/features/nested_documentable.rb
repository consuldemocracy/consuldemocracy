shared_examples "nested documentable" do |documentable_factory_name, new_documentable_path, documentable_path_arguments|
  include ActionView::Helpers
  include DocumentsHelper
  include DocumentablesHelper

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }

  before do
    create(:administrator, user: administrator)

    if documentable_path_arguments
      documentable_path_arguments.each do |argument_name, path_to_value|
        arguments.merge!("#{argument_name}": documentable.send(path_to_value))
      end
    end
  end

  context "Nested documents" do

    context "On documentable new" do

      scenario "Should show new document link" do
        login_as user
        visit send(new_documentable_path, arguments)

        expect(page).to have_selector "#new_document_link", visible: true
      end

      scenario "Should not show new document when documentable max documents allowed limit is reached", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click

        expect(page).to have_selector "#new_document_link", visible: false
      end

      scenario "Should not show max documents warning when no documents added", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        expect(page).to have_selector ".max-documents-notice", visible: false
      end

      scenario "Should show max documents warning when max documents allowed limit is reached", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click

        expect(page).to have_selector ".max-documents-notice", visible: true
      end

      scenario "Should hide max documents warning after any document link", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click
        sleep 1
        find("#new_document_link").click
        sleep 1
        within "#document_0" do
          find("a", text: "Remove document").click
        end
        sleep 1

        expect(page).to have_selector ".max-documents-notice", visible: false
      end

      scenario "Should update nested document file name after choosing a file", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"

        expect(page).to have_selector ".file-name", text: "empty.pdf"
      end

      scenario "Should update nested document file title with file name after choosing a file when no title defined", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1

        expect(find("##{documentable_factory_name}_documents_attributes_0_title").value).to eq "empty.pdf"
      end

      scenario "Should not update nested document file title with file name after choosing a file when title already defined", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        fill_in "#{documentable_factory_name}[documents_attributes][0][title]", with: "Title"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1

        expect(find("##{documentable_factory_name}_documents_attributes_0_title").value).to eq "Title"
      end

      scenario "Should update loading bar style after valid file upload", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        fill_in "#{documentable_factory_name}[documents_attributes][0][title]", with: "Title"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1

        expect(page).to have_selector ".loading-bar.complete"
      end

      scenario "Should update loading bar style after unvalid file upload", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        fill_in "#{documentable_factory_name}[documents_attributes][0][title]", with: "Title"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/logo_header.png"
        sleep 1

        expect(page).to have_selector ".loading-bar.errors"
      end

      scenario "Should update document cached_attachment field after valid file upload", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        fill_in "#{documentable_factory_name}[documents_attributes][0][title]", with: "Title"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1

        expect(find("input[name='#{documentable_factory_name}[documents_attributes][0][cached_attachment]']", visible: false).value).to include("empty.pdf")
      end

      scenario "Should not update document cached_attachment field after unvalid file upload", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        fill_in "#{documentable_factory_name}[documents_attributes][0][title]", with: "Title"
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/logo_header.png"
        sleep 1

        expect(find("input[name='#{documentable_factory_name}[documents_attributes][0][cached_attachment]']", visible: false).value).to eq ""
      end

      scenario "Should show document errors after unvalid file upload", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        sleep 1
        click_on "Create #{documentable_factory_name}"

        within "#document_0" do
          expect(page).to have_content("can't be blank", count: 2)
        end
      end

      scenario "Should delete document after valid file upload and click on remove button", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        sleep 1
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1
        within "#document_0" do
          click_link "Remove document"
        end

        expect(page).not_to have_selector("#document_0")
      end

      scenario "Should delete document after valid file upload and click on remove button", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        sleep 1
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1
        within "#document_0" do
          click_link "Remove document"
        end

        expect(page).to have_content "Document was deleted successfully."
      end

      scenario "Should delete document after valid file upload and click on remove button", :js do
        login_as user
        visit send(new_documentable_path, arguments)

        click_link "Add new document"
        sleep 1
        attach_file "#{documentable_factory_name}[documents_attributes][0][attachment]", "spec/fixtures/files/empty.pdf"
        sleep 1
        within "#document_0" do
          click_link "Remove document"
        end

        expect(page).to have_content "Document was deleted successfully."
      end

    end

  end

end
