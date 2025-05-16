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
  let(:path) do
    case factory
    when :budget_investment
      [
        new_budget_investment_path(budget_id: documentable.budget_id),
        new_management_budget_investment_path(budget_id: documentable.budget_id)
      ].sample
    when :dashboard_action then new_admin_dashboard_action_path
    when :proposal
      [
        new_proposal_path,
        edit_proposal_path(id: documentable.id)
      ].sample
    end
  end
  let(:submit_button_text) do
    case factory
    when :budget_investment then "Create Investment"
    when :dashboard_action then "Save"
    when :proposal
      if edit_path?(path)
        "Save changes"
      else
        "Create proposal"
      end
    end
  end
  let(:notice_text) do
    case factory
    when :budget_investment then "Budget Investment created successfully."
    when :dashboard_action then "Action created successfully"
    when :proposal
      if edit_path?(path)
        "Proposal updated successfully"
      else
        "Proposal created successfully"
      end
    end
  end

  context "New and edit path" do
    describe "When allow attached documents setting is enabled" do
      before do
        Setting["uploads.documents.max_amount"] = 1
        create(:administrator, user: user) if admin_section?(path)
        documentable.update!(author: user) if edit_path?(path)
      end

      scenario "Shows or hides new document link depending on max documents limit" do
        do_login_for(user, management: management_section?(path))
        visit path

        expect(page).to have_link "Add new document"

        click_link "Add new document"

        expect(page).not_to have_link "Add new document"
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

      scenario "Should not update nested document file title with
                file name after choosing a file when title already defined" do
        do_login_for(user, management: management_section?(path))
        visit path

        click_link "Add new document"
        within "#nested-documents" do
          fill_in "Title", with: "My Title"
          attach_file "Choose document", file_fixture("empty.pdf")

          expect(page).to have_css ".loading-bar.complete"
        end

        expect(page).to have_field("Title", with: "My Title")
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

      scenario "Should delete document after valid file upload and click on remove button" do
        do_login_for(user, management: management_section?(path))
        visit path

        documentable_attach_new_file(file_fixture("empty.pdf"))
        click_link "Remove document"

        expect(page).not_to have_css("#nested-documents .document-fields")
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
          expect(page).to have_content "Documents (3)"
          expect(page).to have_link href: /.pdf\Z/, count: 3
          expect(page).to have_link text: "clippy.pdf"
          expect(page).to have_link text: "empty.pdf"
          expect(page).to have_link text: "logo.pdf"
        end
      end
    end

    describe "Only for edit path" do
      let!(:proposal) { create(:proposal, author: user) }

      scenario "Should show persisted documents and remove nested_field" do
        create(:document, documentable: proposal)
        login_as user
        visit edit_proposal_path(proposal)

        expect(page).to have_css ".document-fields", count: 1
      end

      scenario "Should not show add document button when
                documentable has reached maximum of documents allowed" do
        create_list(:document, proposal.class.max_documents_allowed, documentable: proposal)
        login_as user
        visit edit_proposal_path(proposal)

        expect(page).not_to have_css "#new_document_link"
      end

      scenario "Should show add document button after destroy one document" do
        create_list(:document, proposal.class.max_documents_allowed, documentable: proposal)
        login_as user
        visit edit_proposal_path(proposal)
        last_document = all("#nested-documents .document-fields").last
        within last_document do
          click_link "Remove document"
        end

        expect(page).to have_link "Add new document"
      end

      scenario "Should remove nested field after remove document" do
        create(:document, documentable: proposal)
        login_as user
        visit edit_proposal_path(proposal)
        click_link "Remove document"

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

    describe "When allow attached documents setting is disabled" do
      before { Setting["feature.allow_attached_documents"] = false }

      scenario "Add new document button should not be available" do
        do_login_for(user, management: management_section?(path))
        visit path

        expect(page).not_to have_content("Add new document")
      end
    end
  end
end
