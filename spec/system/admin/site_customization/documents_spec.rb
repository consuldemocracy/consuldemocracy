require "rails_helper"

describe "Documents", :admin do
  scenario "Navigation" do
    visit admin_root_path

    within("#side_menu") do
      click_button "Site content"
      click_link "Custom documents"
    end

    expect(page).to have_link "Add new document",
                              href: new_admin_site_customization_document_path
  end

  scenario "Index" do
    3.times { create(:document, :admin) }
    1.times { create(:document) }

    visit admin_site_customization_documents_path

    expect(page).to have_content "There are 3 documents"
    expect(page).not_to have_content "Download file"

    within("tbody tr:first-child") do
      click_button "Copy link"

      page.driver.browser.execute_cdp("Browser.grantPermissions",
                                      permissions: ["clipboardReadWrite"],
                                      origin: page.server_url)
      clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")

      download_link = find_link("Download file", visible: :hidden)[:href]

      expect(clip_text).to include download_link
      expect(clip_text).to match(/^https?:\/\//)
    end
  end

  scenario "Index shows the link to download file when JavaScript is disabled", :no_js do
    create(:document, :admin)

    visit admin_site_customization_documents_path

    ActiveStorage.with(service_urls_expire_in: 0.001.seconds) do
      within("tbody tr:first-child") do
        click_link "Download file"

        expect(page).not_to have_current_path admin_site_customization_documents_path
      end

      document_url = current_path

      visit admin_site_customization_documents_path

      within("tbody tr:first-child") do
        click_link "Download file"

        expect(page).to have_current_path document_url
      end
    end
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

    within("tr", text: "logo.pdf") { expect(page).to have_button "Copy link" }
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
