require "rails_helper"

describe Admin::SiteCustomization::Documents::IndexComponent do
  it "shows a message when there are no documents" do
    render_inline Admin::SiteCustomization::Documents::IndexComponent.new(Document.none.page(1))

    expect(page).to have_content "There are no documents."
  end

  it "shows a link to download the document instead of opening it" do
    create(:document, :admin)

    render_inline Admin::SiteCustomization::Documents::IndexComponent.new(Document.page(1))

    page.find("tbody tr") do |row|
      expect(row).to have_link count: 1
      expect(row).to have_link "Download file", href: /active_storage(.+)\?disposition=attachment/
    end
  end
end
