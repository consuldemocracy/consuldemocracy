require "rails_helper"

describe "Documents", :admin do
  scenario "Navigation" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Site content"
      click_link "Custom documents"
    end

    expect(page).to have_link "Add new document",
                              href: new_admin_site_customization_document_path
  end

  scenario "Index" do
    3.times { create(:document, :admin) }
    1.times { create(:document) }

    document = Document.first
    url = rails_blob_path(document.attachment, disposition: "attachment")

    visit admin_site_customization_documents_path

    expect(page).to have_content "There are 3 documents"
    expect(page).to have_link "Download file", href: url
  end

  scenario "Index shows a link that opens a modal dialog with the document permanent link" do
    document_1 = create(:document, :admin)
    document_2 = create(:document, :admin)
    document_1_url = polymorphic_url(document_1.attachment, host: app_host)
    document_2_url = polymorphic_url(document_2.attachment, host: app_host)

    visit admin_site_customization_documents_path
    within "#document_#{document_1.id}" do
      click_link "Show link"
    end

    expect(page).to have_content(document_1_url)

    click_button "Close modal"
    within "#document_#{document_2.id}" do
      click_link "Show link"
    end

    expect(page).to have_content(document_2_url)
  end

  scenario "Index (empty)" do
    visit admin_site_customization_documents_path

    expect(page).to have_content "There are no documents."
  end

  scenario "Index (pagination)" do
    per_page = 3
    allow(Document).to receive(:default_per_page).and_return(per_page)
    (per_page + 2).times { create(:document, :admin) }

    visit admin_site_customization_documents_path

    expect(page).to have_css "#documents .document-row", count: per_page

    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_link("2", href: admin_site_customization_documents_path(page: 2))
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_css "#documents .document-row", count: 2
  end

  scenario "Create" do
    visit new_admin_site_customization_document_path

    attach_file("document_attachment", file_fixture("logo.pdf"))
    click_button "Upload"

    expect(page).to have_content "Document uploaded successfully"

    within("tr", text: "logo.pdf") { expect(page).to have_link "Download file" }
  end

  scenario "Errors on create" do
    visit new_admin_site_customization_document_path

    click_button "Upload"

    expect(page).to have_content "Invalid document"
  end

  scenario "Destroy" do
    document = create(:document, :admin)

    visit admin_site_customization_documents_path

    within("#document_#{document.id}") do
      accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "Document deleted successfully"
    expect(page).not_to have_content document.title
  end
end
