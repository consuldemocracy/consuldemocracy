shared_examples "documentable" do |documentable_factory_name,
                                   documentable_path,
                                   documentable_path_arguments|
  include ActionView::Helpers

  let(:administrator) { create(:user) }
  let(:user)          { create(:user) }
  let(:arguments)     { {} }
  let(:documentable)  { create(documentable_factory_name, author: user) }
  let!(:document)     { create(:document, documentable: documentable, user: documentable.author) }

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  context "Show documents" do

    scenario "Download action should be able to anyone" do
      visit send(documentable_path, arguments)

      expect(page).to have_link("Download file")
    end

    scenario "Download file link should have blank target attribute" do
      visit send(documentable_path, arguments)

      expect(page).to have_selector("a[target=_blank]", text: "Download file")
    end

    scenario "Download file links should have rel attribute setted to no follow" do
      visit send(documentable_path, arguments)

      expect(page).to have_selector("a[rel=nofollow]", text: "Download file")
    end

    describe "Destroy action" do

      scenario "Should not be able when no user logged in" do
        visit send(documentable_path, arguments)

        expect(page).not_to have_link("Destroy document")
      end

      scenario "Should be able when documentable author is logged in" do
        login_as documentable.author
        visit send(documentable_path, arguments)

        expect(page).to have_link("Destroy document")
      end

      scenario "Administrators cannot destroy documentables they have not authored" do
        login_as(administrator)
        visit send(documentable_path, arguments)

        expect(page).not_to have_link("Destroy document")
      end

      scenario "Users cannot destroy documentables they have not authored" do
        login_as(create(:user))
        visit send(documentable_path, arguments)

        expect(page).not_to have_link("Destroy document")
      end

    end

    describe "When allow attached documents setting is enabled" do
      before do
        Setting["feature.allow_attached_documents"] = true
      end

      after do
        Setting["feature.allow_attached_documents"] = false
      end

      scenario "Documents list should be available" do
        login_as(user)
        visit send(documentable_path, arguments)

        expect(page).to have_css("#documents")
        expect(page).to have_content("Documents (1)")
      end

      scenario "Documents list increase documents number" do
        create(:document, documentable: documentable, user: documentable.author)
        login_as(user)
        visit send(documentable_path, arguments)

        expect(page).to have_css("#documents")
        expect(page).to have_content("Documents (2)")
      end
    end

    describe "When allow attached documents setting is disabled" do
      before do
        Setting["feature.allow_attached_documents"] = false
      end

      after do
        Setting["feature.allow_attached_documents"] = true
      end

      scenario "Documents list should not be available" do
        login_as(create(:user))
        visit send(documentable_path, arguments)

        expect(page).not_to have_css("#documents")
      end
    end

  end

  context "Destroy" do

    scenario "Should show success notice after successful document upload" do
      login_as documentable.author

      visit send(documentable_path, arguments)

      within "#document_#{document.id}" do
        click_on "Destroy document"
      end

      expect(page).to have_content "Document was deleted successfully."
    end

    scenario "Should hide documents tab if there is no documents" do
      login_as documentable.author

      visit send(documentable_path, arguments)

      within "#document_#{document.id}" do
        click_on "Destroy document"
      end

      expect(page).not_to have_content "Documents (0)"
    end

    scenario "Should redirect to documentable path after successful deletion" do
      login_as documentable.author

      visit send(documentable_path, arguments)

      within "#document_#{document.id}" do
        click_on "Destroy document"
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
    expect(page).to have_css ".loading-bar.complete"
  else
    expect(page).to have_css ".loading-bar.errors"
  end
end
