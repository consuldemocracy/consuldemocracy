require "rails_helper"

describe Admin::SiteCustomization::Pages::IndexComponent,
         controller: Admin::SiteCustomization::PagesController do
  before { SiteCustomization::Page.delete_all }

  it "shows date in created_at and updated_at fields" do
    custom_page = create(:site_customization_page, created_at: "2015-07-15 13:32:13")
    custom_page.update!(updated_at: "2019-12-09 09:19:29")

    render_inline Admin::SiteCustomization::Pages::IndexComponent.new(SiteCustomization::Page.page(1))

    expect(page).to have_content "July 15, 2015 13:32"
    expect(page).to have_content "December 09, 2019 09:19"
  end
end
