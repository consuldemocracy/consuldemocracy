shared_examples "nested documentable" do |login_as_name, documentable_factory_name, path,
                                          documentable_path_arguments, fill_resource_method_name,
                                          submit_button, documentable_success_notice, management: false|
  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user, :level_two) }
  let!(:arguments)              { {} }
  if documentable_factory_name == "dashboard_action"
    let!(:documentable)           { create(documentable_factory_name) }
  else
    let!(:documentable)           { create(documentable_factory_name, author: user) }
  end
  let!(:user_to_login) { send(login_as_name) }
  let(:management) { management }

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  describe "at #{path}" do
    scenario "Should show new document link when max documents allowed limit is not reached" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      expect(page).to have_css "#new_document_link"
    end

    scenario "Should not show new document link when
              documentable max documents allowed limit is reached" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      expect(page).not_to have_css "#new_document_link"
    end

    scenario "Should not show max documents warning when no documents added" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      expect(page).not_to have_css ".max-documents-notice"
    end

    scenario "Should show max documents warning when max documents allowed limit is reached" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)
      documentable.class.max_documents_allowed.times.each do
        documentable_attach_new_file(file_fixture("empty.pdf"))
      end

      expect(page).to have_css ".max-documents-notice"
      expect(page).to have_content "Remove document"
    end

    scenario "Should hide max documents warning after any document removal" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable.class.max_documents_allowed.times.each do
        click_link "Add new document"
      end

      all("a", text: "Cancel").last.click

      expect(page).not_to have_css ".max-documents-notice"
    end

    scenario "Should update nested document file name after choosing a file" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      click_link "Add new document"
      within "#nested-documents" do
        attach_file "Choose document", file_fixture("empty.pdf")

        expect(page).to have_css ".loading-bar.complete"
      end

      expect(page).to have_css ".file-name", text: "empty.pdf"
    end

    scenario "Should update nested document file title with
              file name after choosing a file when no title defined" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable_attach_new_file(file_fixture("empty.pdf"))

      expect_document_has_title(0, "empty.pdf")
    end

    scenario "Should not update nested document file title with
              file name after choosing a file when title already defined" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      click_link "Add new document"
      within "#nested-documents" do
        input = find("input[name$='[title]']")
        fill_in input[:id], with: "My Title"
        attach_file "Choose document", file_fixture("empty.pdf")

        expect(page).to have_css ".loading-bar.complete"
      end

      expect_document_has_title(0, "My Title")
    end

    scenario "Should update loading bar style after valid file upload" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable_attach_new_file(file_fixture("empty.pdf"))

      expect(page).to have_css ".loading-bar.complete"
    end

    scenario "Should update loading bar style after invalid file upload" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable_attach_new_file(file_fixture("logo_header.gif"), false)

      expect(page).to have_css ".loading-bar.errors"
    end

    scenario "Should update document cached_attachment field after valid file upload" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      click_link "Add new document"

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty

      attach_file "Choose document", file_fixture("empty.pdf")

      expect(page).to have_css(".loading-bar.complete")
      expect(cached_attachment_field.value).not_to be_empty
    end

    scenario "Should not update document cached_attachment field after invalid file upload" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable_attach_new_file(file_fixture("logo_header.gif"), false)

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty
    end

    scenario "Should show document errors after documentable submit with
              empty document fields" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      click_link "Add new document"
      click_on submit_button

      within "#nested-documents .document" do
        expect(page).to have_content("can't be blank", count: 2)
      end
    end

    scenario "Should delete document after valid file upload and click on remove button" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      documentable_attach_new_file(file_fixture("empty.pdf"))
      click_link "Remove document"

      expect(page).not_to have_css("#nested-documents .document")
    end

    scenario "Should show successful notice when
              resource filled correctly without any nested documents" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      send(fill_resource_method_name) if fill_resource_method_name
      click_on submit_button

      expect(page).to have_content documentable_success_notice
    end

    scenario "Should show successful notice when
              resource filled correctly and after valid file uploads" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      documentable_attach_new_file(file_fixture("empty.pdf"))
      click_on submit_button

      expect(page).to have_content documentable_success_notice
    end

    scenario "Should show new document after successful creation with one uploaded file",
             unless: documentable_factory_name == "dashboard_action" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      documentable_attach_new_file(file_fixture("empty.pdf"))
      click_on submit_button

      expect(page).to have_content documentable_success_notice

      documentable_redirected_to_resource_show_or_navigate_to

      expect(page).to have_content "Documents"
      expect(page).to have_content "empty.pdf"

      # Review
      # Doble check why the file is stored with a name different to empty.pdf
      expect(page).to have_css("a[href$='.pdf']")
    end

    scenario "Should show resource with new document after successful creation with
              maximum allowed uploaded files", unless: documentable_factory_name == "dashboard_action" do
      do_login_for user_to_login, management: management
      visit send(path, arguments)

      send(fill_resource_method_name) if fill_resource_method_name

      %w[clippy empty logo].take(documentable.class.max_documents_allowed).each do |filename|
        documentable_attach_new_file(file_fixture("#{filename}.pdf"))
      end

      click_on submit_button

      expect(page).to have_content documentable_success_notice

      documentable_redirected_to_resource_show_or_navigate_to

      expect(page).to have_content "Documents (#{documentable.class.max_documents_allowed})"
    end

    if path.include? "edit"
      scenario "Should show persisted documents and remove nested_field" do
        create(:document, documentable: documentable)
        do_login_for user_to_login, management: management
        visit send(path, arguments)

        expect(page).to have_css ".document", count: 1
      end

      scenario "Should not show add document button when
                documentable has reached maximum of documents allowed" do
        create_list(:document, documentable.class.max_documents_allowed, documentable: documentable)
        do_login_for user_to_login, management: management
        visit send(path, arguments)

        expect(page).not_to have_css "#new_document_link"
      end

      scenario "Should show add document button after destroy one document" do
        create_list(:document, documentable.class.max_documents_allowed, documentable: documentable)
        do_login_for user_to_login, management: management
        visit send(path, arguments)
        last_document = all("#nested-documents .document").last
        within last_document do
          click_on "Remove document"
        end

        expect(page).to have_css "#new_document_link"
      end

      scenario "Should remove nested field after remove document" do
        create(:document, documentable: documentable)
        do_login_for user_to_login, management: management
        visit send(path, arguments)
        click_on "Remove document"

        expect(page).not_to have_css ".document"
      end

      scenario "Same attachment URL after editing the title" do
        do_login_for user_to_login, management: management

        visit send(path, arguments)
        documentable_attach_new_file(file_fixture("empty.pdf"))
        within_fieldset("Documents") { fill_in "Title", with: "Original" }
        click_button submit_button

        expect(page).to have_content documentable_success_notice

        original_url = find_link("Download file")[:href]

        visit send(path, arguments)
        within_fieldset("Documents") { fill_in "Title", with: "Updated" }
        click_button submit_button

        expect(page).to have_content documentable_success_notice
        expect(find_link("Download file")[:href]).to eq original_url
      end
    end

    describe "When allow attached documents setting is disabled" do
      before do
        Setting["feature.allow_attached_documents"] = false
      end

      scenario "Add new document button should not be available" do
        do_login_for user_to_login, management: management
        visit send(path, arguments)

        expect(page).not_to have_content("Add new document")
      end
    end
  end
end
