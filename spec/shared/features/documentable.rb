shared_examples "documentable" do |documentable_factory_name, documentable_path, documentable_path_arguments|
  include ActionView::Helpers

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:arguments)              { {} }
  let!(:documentable)           { create(documentable_factory_name, author: user) }

  before do
    create(:administrator, user: administrator)

    documentable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  context "Show documents tab" do

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
    expect(page).to have_css ".loading-bar.complete"
  else
    expect(page).to have_css ".loading-bar.errors"
  end
end