shared_examples "admin nested documentable" do |login_as_name, documentable_factory_name, path,
                                          documentable_path_arguments, fill_resource_method_name,
                                          submit_button, documentable_success_notice, management: false|
  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user, :level_two) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }
  let!(:user_to_login) { send(login_as_name) }
  let(:management) { management }

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  describe "at #{path}" do
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
        click_link "Add new document"
        attach_file "Choose document", file_fixture("empty.pdf")
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
