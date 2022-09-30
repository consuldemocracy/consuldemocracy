require "rails_helper"

describe "robots.txt" do
  scenario "uses the default sitemap for the default tenant" do
    visit "/robots.txt"

    expect(page).to have_content "Sitemap: #{app_host}/sitemap.xml"
  end

  scenario "uses a different sitemap for other tenants" do
    create(:tenant, schema: "cyborgs")

    with_subdomain("cyborgs") do
      visit "/robots.txt"

      expect(page).to have_content "Sitemap: http://cyborgs.lvh.me:#{app_port}/tenants/cyborgs/sitemap.xml"
    end
  end
end
