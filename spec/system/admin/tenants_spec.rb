require "rails_helper"

describe "Tenants", :admin, :seed_tenants do
  before { allow(Tenant).to receive(:default_host).and_return("localhost") }

  scenario "Create" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Settings"
      click_link "Multitenancy"
    end

    click_link "Create tenant"
    fill_in "Subdomain", with: "earth"
    fill_in "Name", with: "Earthlings"
    click_button "Create tenant"

    expect(page).to have_content "Tenant created successfully"

    within("tr", text: "earth") { click_link "View" }

    expect(current_host).to eq "http://earth.lvh.me"
    expect(page).to have_current_path root_path
    expect(page).to have_link "Sign in"
  end

  scenario "Update" do
    create(:tenant, schema: "moon")

    visit admin_tenants_path
    within("tr", text: "moon") { click_link "Edit" }

    fill_in "Subdomain", with: "the-moon"
    click_button "Update tenant"

    expect(page).to have_content "Tenant updated successfully"

    within("tr", text: "the-moon") { click_link "View" }

    expect(current_host).to eq "http://the-moon.lvh.me"
    expect(page).to have_current_path root_path
    expect(page).to have_link "Sign in"
  end
end
