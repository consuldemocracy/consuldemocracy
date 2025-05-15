module Attachables
  def imageable_attach_new_file(path, success: true)
    click_link "Add image"
    within "#nested-image" do
      image = find(".image-fields")
      attach_file "Choose image", path
      within image do
        if success
          expect(page).to have_css(".loading-bar.complete")
        else
          expect(page).to have_css(".loading-bar.errors")
        end
      end
    end
  end

  def documentable_attach_new_file(path, success: true)
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
