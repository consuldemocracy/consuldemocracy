require "rails_helper"

describe "Nested documentable" do
  factories = [
    :dashboard_action
  ]

  let(:factory) { factories.sample }
  let!(:documentable) { create(factory) }
  let!(:user) { create(:administrator).user }
  let(:path) { new_admin_dashboard_action_path }
  let(:submit_button_text) { "Save" }
  let(:notice_text) { "Action created successfully" }

  context "New path" do
    describe "When allow attached documents setting is enabled" do
      scenario "Should show new document link when max documents allowed limit is not reached" do
        login_as user
        visit path

        expect(page).to have_link "Add new document"
      end

      scenario "Should not show new document link when
                documentable max documents allowed limit is reached" do
        login_as user
        visit path

        documentable.class.max_documents_allowed.times.each do
          click_link "Add new document"
        end

        expect(page).not_to have_css "#new_document_link"
      end

      scenario "Should not show max documents warning when no documents added" do
        login_as user
        visit path

        expect(page).not_to have_css ".max-documents-notice"
      end

      scenario "Should show max documents warning when max documents allowed limit is reached" do
        login_as user
        visit path

        documentable.class.max_documents_allowed.times.each do
          documentable_attach_new_file(file_fixture("empty.pdf"))
        end

        expect(page).to have_css ".max-documents-notice"
        expect(page).to have_content "Remove document"
      end

      scenario "Should hide max documents warning after any document removal" do
        login_as user
        visit path

        documentable.class.max_documents_allowed.times.each do
          click_link "Add new document"
        end

        all("a", text: "Cancel").last.click

        expect(page).not_to have_css ".max-documents-notice"
      end

      scenario "Should update nested document file name after choosing a file" do
        login_as user
        visit path

        click_link "Add new document"
        within "#nested-documents" do
          attach_file "Choose document", file_fixture("empty.pdf")

          expect(page).to have_css ".loading-bar.complete"
        end

        expect(page).to have_css ".file-name", text: "empty.pdf"
      end

      scenario "Should update nested document file title with
                file name after choosing a file when no title defined" do
        login_as user
        visit path

        documentable_attach_new_file(file_fixture("empty.pdf"))

        expect_document_has_title(0, "empty.pdf")
      end

      scenario "Should not update nested document file title with
                file name after choosing a file when title already defined" do
        login_as user
        visit path

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
        login_as user
        visit path

        documentable_attach_new_file(file_fixture("empty.pdf"))

        expect(page).to have_css ".loading-bar.complete"
      end

      scenario "Should update loading bar style after invalid file upload" do
        login_as user
        visit path

        documentable_attach_new_file(file_fixture("logo_header.gif"), false)

        expect(page).to have_css ".loading-bar.errors"
      end

      scenario "Should update document cached_attachment field after valid file upload" do
        login_as user
        visit path

        click_link "Add new document"

        cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
        expect(cached_attachment_field.value).to be_empty

        attach_file "Choose document", file_fixture("empty.pdf")

        expect(page).to have_css(".loading-bar.complete")
        expect(cached_attachment_field.value).not_to be_empty
      end

      scenario "Should not update document cached_attachment field after invalid file upload" do
        login_as user
        visit path

        documentable_attach_new_file(file_fixture("logo_header.gif"), false)

        cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
        expect(cached_attachment_field.value).to be_empty
      end

      scenario "Should show document errors after documentable submit with empty document fields" do
        login_as user
        visit path

        click_link "Add new document"
        click_button submit_button_text

        within "#nested-documents .document-fields" do
          expect(page).to have_content("can't be blank", count: 2)
        end
      end

      scenario "Should delete document after valid file upload and click on remove button" do
        login_as user
        visit path

        documentable_attach_new_file(file_fixture("empty.pdf"))
        click_link "Remove document"

        expect(page).not_to have_css("#nested-documents .document-fields")
      end

      scenario "Should show successful notice when resource filled correctly without any nested documents" do
        login_as user
        visit path

        fill_dashboard_action
        click_button submit_button_text

        expect(page).to have_content notice_text
      end

      scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
        login_as user
        visit path

        fill_dashboard_action

        documentable_attach_new_file(file_fixture("empty.pdf"))
        click_button submit_button_text

        expect(page).to have_content notice_text
      end
    end

    describe "When allow attached documents setting is disabled" do
      before { Setting["feature.allow_attached_documents"] = false }

      scenario "Add new document button should not be available" do
        login_as user
        visit path

        expect(page).not_to have_content("Add new document")
      end
    end
  end

  def fill_dashboard_action
    fill_in :dashboard_action_title, with: "Dashboard title"
    fill_in_ckeditor "Description", with: "Dashboard description"
  end
end
