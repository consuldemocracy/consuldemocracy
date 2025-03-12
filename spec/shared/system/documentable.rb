shared_examples "documentable" do |documentable_factory_name, documentable_path, documentable_path_arguments|
  let(:user)          { create(:user) }
  let(:arguments)     { {} }
  let(:documentable)  { create(documentable_factory_name, author: user) }
  let!(:document)     { create(:document, documentable: documentable, user: documentable.author) }

  before do
    documentable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": documentable.send(path_to_value))
    end
  end

  context "Show documents" do
    scenario "Download action should be availabe to anyone and open in the same tab" do
      visit send(documentable_path, arguments)

      within "#documents" do
        expect(page).to have_link text: document.title
        expect(page).to have_css "a[rel=nofollow]", text: document.title
        expect(page).not_to have_css "a[target=_blank]"
      end
    end

    describe "Destroy action" do
      scenario "Should not be able when no user logged in" do
        visit send(documentable_path, arguments)

        expect(page).not_to have_button "Delete document"
      end

      scenario "Should be able when documentable author is logged in" do
        login_as documentable.author
        visit send(documentable_path, arguments)

        expect(page).to have_button "Delete document"
      end

      scenario "Administrators cannot destroy documentables they have not authored", :admin do
        visit send(documentable_path, arguments)

        expect(page).not_to have_button "Delete document"
      end

      scenario "Users cannot destroy documentables they have not authored" do
        login_as(create(:user))
        visit send(documentable_path, arguments)

        expect(page).not_to have_button "Delete document"
      end
    end

    describe "When allow attached documents setting is enabled" do
      before do
        Setting["feature.allow_attached_documents"] = true
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
        accept_confirm { click_button "Delete document" }
      end

      expect(page).to have_content "Document was deleted successfully."
      expect(page).not_to have_content "Documents (0)"

      within "##{ActionView::RecordIdentifier.dom_id(documentable)}" do
        expect(page).to have_css "h1", text: documentable.title
      end
    end
  end
end
