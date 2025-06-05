require "rails_helper"

describe "Nested documentable" do
  factories = [
    :budget_investment,
    :dashboard_action,
    :proposal
  ]

  let(:factory) { factories.sample }
  let!(:documentable) { create(factory) }
  let!(:user) { create(:user, :level_two) }
  let(:path) { attachable_path_for(factory, documentable) }
  let(:submit_button_text) { submit_button_text_for(factory, path) }
  let(:notice_text) { notice_text_for(factory, path) }

  context "New and edit path" do
    before do
      Setting["uploads.documents.max_amount"] = 1
      create(:administrator, user: user) if admin_section?(path)
      documentable.update!(author: user) if edit_path?(path)
    end

    scenario "Shows or hides new document link depending on max documents limit" do
      do_login_for(user, management: management_section?(path))
      visit path

      expect(page).to have_link "Add new document"

      documentable_attach_new_file(file_fixture("empty.pdf"))

      expect(page).not_to have_link "Add new document"

      click_link "Remove document"

      expect(page).to have_link "Add new document"
    end

    scenario "Shows or hides max documents warning depending on max documents limit" do
      do_login_for(user, management: management_section?(path))
      visit path

      expect(page).not_to have_css ".max-documents-notice"
      expect(page).not_to have_content "Remove document"

      documentable_attach_new_file(file_fixture("empty.pdf"))

      expect(page).to have_css ".max-documents-notice"

      click_link "Remove document"

      expect(page).not_to have_css ".max-documents-notice"
    end

    scenario "Should update file name and title after choosing a file with no title defined" do
      do_login_for(user, management: management_section?(path))
      visit path

      documentable_attach_new_file(file_fixture("empty.pdf"))

      expect(page).to have_css ".file-name", text: "empty.pdf"
      expect(page).to have_field("Title", with: "empty.pdf")
    end

    scenario "Should not change existing titles except when removing the document" do
      do_login_for(user, management: management_section?(path))
      visit path

      click_link "Add new document"

      expect(page).not_to have_link "Add new document"

      within "#nested-documents" do
        fill_in "Title", with: "My Title"
        attach_file "Choose document", file_fixture("empty.pdf")

        expect(page).to have_css ".loading-bar.complete"
        expect(page).to have_field "Title", with: "My Title"

        click_link "Remove document"

        expect(page).not_to have_css ".document-fields"
        expect(page).not_to have_field "Title"
      end

      click_link "Add new document"

      within "#nested-documents" do
        expect(page).to have_field "Title", with: ""
        expect(page).not_to have_field "Title", with: "My Title"
      end
    end

    scenario "Should update document cached_attachment field after valid file upload" do
      do_login_for(user, management: management_section?(path))
      visit path

      click_link "Add new document"

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty

      attach_file "Choose document", file_fixture("empty.pdf")

      expect(page).to have_css(".loading-bar.complete")
      expect(cached_attachment_field.value).not_to be_empty
    end

    scenario "Should not update document cached_attachment field after invalid file upload" do
      do_login_for(user, management: management_section?(path))
      visit path

      documentable_attach_new_file(file_fixture("logo_header.gif"), success: false)

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty
    end

    scenario "Should show document errors after documentable submit with empty document fields" do
      do_login_for(user, management: management_section?(path))
      visit path

      click_link "Add new document"
      click_button submit_button_text

      within "#nested-documents .document-fields" do
        expect(page).to have_content("can't be blank", count: 2)
      end
    end

    scenario "Should show successful notice when resource filled correctly without any nested documents" do
      do_login_for(user, management: management_section?(path))
      visit path

      fill_in_required_fields(factory, path)
      click_button submit_button_text

      expect(page).to have_content notice_text
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
      Setting["uploads.documents.max_amount"] = 3
      do_login_for(user, management: management_section?(path))
      visit path

      fill_in_required_fields(factory, path)

      %w[clippy empty logo].each do |filename|
        click_link "Add new document"

        attach_file "Choose document", file_fixture("#{filename}.pdf")

        within all(".document-fields").last do
          expect(page).to have_css ".loading-bar.complete"
        end
      end

      expect(page).not_to have_link "Add new document"

      click_button submit_button_text

      expect(page).to have_content notice_text
      if factory != :dashboard_action
        within "#documents" do
          expect(page).to have_content "Documents (3)"
          expect(page).to have_link href: /.pdf\Z/, count: 3
          expect(page).to have_link text: "empty.pdf"
          expect(page).to have_css "a[rel=nofollow]"
          expect(page).to have_link text: "clippy.pdf"
          expect(page).to have_css "a[rel=nofollow]"
          expect(page).to have_link text: "logo.pdf"
          expect(page).to have_css "a[rel=nofollow]"
          expect(page).not_to have_css "a[target=_blank]"
        end
      end
    end

    describe "Metadata" do
      let(:factory) { (factories - [:dashboard_action]).sample }

      scenario "download document without metadata" do
        do_login_for(user, management: management_section?(path))
        visit path

        fill_in_required_fields(factory, path)
        documentable_attach_new_file(file_fixture("logo_with_metadata.pdf"))
        click_button submit_button_text

        expect(page).to have_content notice_text

        io = URI.parse(find_link(text: "PDF")[:href]).open
        reader = PDF::Reader.new(io)

        expect(reader.info[:Keywords]).not_to eq "Test Metadata"
        expect(reader.info[:Author]).not_to eq "Test Developer"
        expect(reader.info[:Title]).not_to eq "logo_with_metadata.pdf"
        expect(reader.info[:Producer]).not_to eq "Test Producer"
        expect(reader.info).to eq({})
      end
    end

    describe "When allow attached documents setting is disabled" do
      before { Setting["feature.allow_attached_documents"] = false }

      scenario "Add new document button should not be available" do
        do_login_for(user, management: management_section?(path))
        visit path

        expect(page).not_to have_content("Add new document")
      end
    end
  end

  describe "Only for edit path" do
    let!(:proposal) { create(:proposal, author: user) }

    scenario "Should show persisted documents and remove nested_field" do
      Setting["uploads.documents.max_amount"] = 1
      create(:document, documentable: proposal)
      login_as user
      visit edit_proposal_path(proposal)

      expect(page).not_to have_link "Add new document"
      expect(page).to have_css ".document-fields", count: 1

      click_link "Remove document"

      expect(page).to have_link "Add new document"
      expect(page).not_to have_css ".document-fields"
    end

    scenario "Same attachment URL after editing the title" do
      login_as user
      visit edit_proposal_path(proposal)

      documentable_attach_new_file(file_fixture("empty.pdf"))
      within_fieldset("Documents") { fill_in "Title", with: "Original" }
      click_button "Save changes"

      expect(page).to have_content "Proposal updated successfully"

      original_url = find_link(text: "Original")[:href]

      visit edit_proposal_path(proposal)
      within_fieldset("Documents") { fill_in "Title", with: "Updated" }
      click_button "Save changes"

      expect(page).to have_content "Proposal updated successfully"
      expect(find_link(text: "Updated")[:href]).to eq original_url
    end
  end

  context "Show path" do
    let(:factory) { (factories - [:dashboard_action]).sample }
    let(:path) { polymorphic_path(documentable) }

    scenario "Documents list should not be available when allow attached documents setting is disabled" do
      Setting["feature.allow_attached_documents"] = false
      create(:document, documentable: documentable)
      visit path

      expect(page).not_to have_css("#documents")
    end

    context "Destroy" do
      scenario "Should show success notice after successful document upload" do
        create(:document, documentable: documentable)
        documentable.update!(author: user)
        login_as(user)
        visit path

        accept_confirm { click_button "Delete document" }

        expect(page).to have_content "Document was deleted successfully."
        expect(page).not_to have_content "Documents (0)"

        within "##{ActionView::RecordIdentifier.dom_id(documentable)}" do
          expect(page).to have_css "h1", text: documentable.title
        end
      end
    end
  end
end
