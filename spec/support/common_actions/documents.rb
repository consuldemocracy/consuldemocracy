module Documents
  def documentable_attach_new_file(path, success = true)
    click_link "Add new document"

    document = all(".document-fields").last
    attach_file "Choose document", path

    within document do
      if success
        expect(page).to have_css ".loading-bar.complete"
      else
        expect(page).to have_css ".loading-bar.errors"
      end
    end
  end
end
