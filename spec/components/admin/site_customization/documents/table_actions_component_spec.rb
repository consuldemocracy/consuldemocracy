require "rails_helper"

describe Admin::SiteCustomization::Documents::TableActionsComponent do
  it "renders a link to download the document, a button to copy its link and a button to delete it" do
    document = create(:document, :admin)

    render_inline Admin::SiteCustomization::Documents::TableActionsComponent.new(document)

    expect(page).to have_link count: 1
    expect(page).to have_link "Download file", href: /active_storage/
    expect(page).to have_button count: 2
    expect(page).to have_css "button[type=button]", exact_text: "Copy link"
    expect(page).to have_css "button[type=submit]", exact_text: "Delete"
  end
end
