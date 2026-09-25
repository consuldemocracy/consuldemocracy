require "rails_helper"

describe Admin::SiteCustomization::Documents::IndexComponent do
  it "shows a message when there are no documents" do
    render_inline Admin::SiteCustomization::Documents::IndexComponent.new(Document.none.page(1))

    expect(page).to have_content "There are no documents."
  end
end
