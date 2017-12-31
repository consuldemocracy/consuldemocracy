shared_examples "nested documentable" do |login_as_name, documentable_factory_name, path, documentable_path_arguments, fill_resource_method_name, submit_button, documentable_success_notice|
  include ActionView::Helpers
  include DocumentsHelper
  include DocumentablesHelper

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user, :level_two) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }
  let!(:user_to_login)          { send(login_as_name)}

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  describe "at #{path}" do

    scenario "Should show new document link when max documents allowed limit is not reached" do
      login_as user_to_login
      visit send(path, arguments)

      expect(page).to have_css "#new_document_link", visible: true
    end

    scenario "Should not show new document link when documentable max documents allowed limit is reached", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      expect(page).to have_css "#new_document_link", visible: false
    end

    scenario "Should not show max documents warning when no documents added", :js do
      login_as user_to_login
      visit send(path, arguments)

      expect(page).to have_css ".max-documents-notice", visible: false
    end

    scenario "Should show max documents warning when max documents allowed limit is reached", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      expect(page).to have_css ".max-documents-notice", visible: true
    end

    scenario "Should hide max documents warning after any document removal", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      all("a", text: "Remove document").last.click

      expect(page).to have_css ".max-documents-notice", visible: false
    end

    scenario "Should update nested document file name after choosing a file", :js do
      login_as user_to_login
      visit send(path, arguments)

      click_link "Add new document"
      within "#nested-documents" do
        document = find(".document input[type=file]", visible: false)
        attach_file(document[:id], "spec/fixtures/files/empty.pdf", make_visible: true)
      end

      expect(page).to have_css ".file-name", text: "empty.pdf"
    end

    scenario "Should update nested document file title with file name after choosing a file when no title defined", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")

      expect_document_has_title(0, "empty.pdf")
    end

    scenario "Should not update nested document file title with file name after choosing a file when title already defined", :js do
      login_as user_to_login
      visit send(path, arguments)

      click_link "Add new document"
      within "#nested-documents" do
        input = find("input[name$='[title]']")
        fill_in input[:id], with: "My Title"
        document_input = find("input[type=file]", visible: false)
        attach_file(document_input[:id], "spec/fixtures/files/empty.pdf", make_visible: true)
      end

      expect_document_has_title(0, "My Title")
    end

    scenario "Should update loading bar style after valid file upload", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")

      expect(page).to have_css ".loading-bar.complete"
    end

    scenario "Should update loading bar style after unvalid file upload", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/logo_header.png", false)

      expect(page).to have_css ".loading-bar.errors"
    end

    scenario "Should update document cached_attachment field after valid file upload", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")

      expect_document_has_cached_attachment(0, ".pdf")
    end

    scenario "Should not update document cached_attachment field after unvalid file upload", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/logo_header.png", false)

      expect_document_has_cached_attachment(0, "")
    end

    scenario "Should show document errors after documentable submit with empty document fields", :js do
      login_as user_to_login
      visit send(path, arguments)

      click_link "Add new document"
      click_on submit_button

      within "#nested-documents .document" do
        expect(page).to have_content("can't be blank", count: 2)
      end
    end

    scenario "Should delete document after valid file upload and click on remove button", :js do
      login_as user_to_login
      visit send(path, arguments)

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")
      click_link "Remove document"

      expect(page).not_to have_css("#nested-documents .document")
    end

    scenario "Should show successful notice when resource filled correctly without any nested documents", :js do
      login_as user_to_login
      visit send(path, arguments)

      send(fill_resource_method_name) if fill_resource_method_name
      click_on submit_button

      expect(page).to have_content documentable_success_notice
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads", :js do
      login_as user_to_login
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")
      click_on submit_button

      expect(page).to have_content documentable_success_notice
    end

    scenario "Should show new document after successful creation with one uploaded file", :js do
      login_as user_to_login
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      documentable_attach_new_file(documentable_factory_name, 0, "spec/fixtures/files/empty.pdf")
      click_on submit_button

      documentable_redirected_to_resource_show_or_navigate_to

      expect(page).to have_content "Documents"

      find("#tab-documents-label").click
      expect(page).to have_content "empty.pdf"

      # Review
      # Doble check why the file is stored with a name different to empty.pdf
      expect(page).to have_css("a[href$='.pdf']")
    end

    scenario "Should show resource with new document after successful creation with maximum allowed uploaded files", :js do
      skip "due to weird behaviour"
      page.driver.resize_window 1200, 2500
      login_as user_to_login
      visit send(path, arguments)

      send(fill_resource_method_name) if fill_resource_method_name

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      documents = all(".document")
      documents.each_with_index do |document, index|
        document_input = document.find("input[type=file]", visible: false)
        attach_file(document_input[:id], "spec/fixtures/files/empty.pdf", make_visible: true)
        within all(".document")[index] do
          expect(page).to have_css ".loading-bar.complete"
        end
      end
      click_on submit_button
      documentable_redirected_to_resource_show_or_navigate_to

      expect(page).to have_content "Documents (#{documentable.class.max_documents_allowed})"
    end

    if path.include? "edit"

      scenario "Should show persisted documents and remove nested_field" do
        login_as user_to_login
        create(:document, documentable: documentable)
        visit send(path, arguments)

        expect(page).to have_css ".document", count: 1
      end

      scenario "Should not show add document button when documentable has reached maximum of documents allowed", :js do
        login_as user_to_login
        create_list(:document, documentable.class.max_documents_allowed, documentable: documentable)
        visit send(path, arguments)

        expect(page).to have_css "#new_document_link", visible: false
      end

      scenario "Should show add document button after destroy one document", :js do
        login_as user_to_login
        create_list(:document, documentable.class.max_documents_allowed, documentable: documentable)
        visit send(path, arguments)
        last_document = all("#nested-documents .document").last
        within last_document do
          click_on "Remove document"
        end

        expect(page).to have_css "#new_document_link", visible: true
      end

      scenario "Should remove nested field after remove document", :js do
        login_as user_to_login
        create(:document, documentable: documentable)
        visit send(path, arguments)
        click_on "Remove document"

        expect(page).not_to have_css ".document"
      end

    end

  end

end

def documentable_redirected_to_resource_show_or_navigate_to
  find("a", text: "Not now, go to my proposal")
  click_on "Not now, go to my proposal"
rescue
  return
end

def documentable_attach_new_file(_documentable_factory_name, index, path, success = true)
  click_link "Add new document"
  document = all(".document")[index]
  document_input = document.find("input[type=file]", visible: false)
  attach_file(document_input[:id], path, make_visible: true)
  within document do
    if success
      expect(page).to have_css ".loading-bar.complete"
    else
      expect(page).to have_css ".loading-bar.errors"
    end
  end
end

def expect_document_has_title(index, title)
  document = all(".document")[index]

  within document do
    expect(find("input[name$='[title]']").value).to eq title
  end
end

def expect_document_has_cached_attachment(index, extension)
  document = all(".document")[index]

  within document do
    expect(find("input[name$='[cached_attachment]']", visible: false).value).to end_with(extension)
  end
end

def documentable_fill_new_valid_proposal
  fill_in :proposal_title, with: "Proposal title #{rand(9999)}"
  fill_in :proposal_summary, with: "Proposal summary"
  fill_in :proposal_question, with: "Proposal question?"
  check :proposal_terms_of_service
end

def documentable_fill_new_valid_budget_investment
  page.select documentable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in :budget_investment_title, with: "Budget investment title"
  fill_in_ckeditor "budget_investment_description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end
