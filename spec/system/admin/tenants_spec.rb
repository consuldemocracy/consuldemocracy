require "rails_helper"

describe "Tenants", :admin, :seed_tenants do
  before { allow(Tenant).to receive(:default_host).and_return("localhost") }

  describe "Create" do
    scenario "Tenant with subdomain" do
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

      click_link "earth.lvh.me"

      expect(current_host).to eq "http://earth.lvh.me"
      expect(page).to have_current_path root_path
      expect(page).to have_link "Sign in"
    end

    scenario "Tenant with domain" do
      visit new_admin_tenant_path

      choose "Use a different domain to access this tenant"
      fill_in "Domain", with: "earth.lvh.me"
      fill_in "Name", with: "Earthlings"
      click_button "Create tenant"

      click_link "earth.lvh.me"

      expect(current_host).to eq "http://earth.lvh.me"
      expect(page).to have_current_path root_path
      expect(page).to have_link "Sign in"
    end
  end

  scenario "Update" do
    create(:tenant, schema: "moon")

    visit admin_tenants_path
    within("tr", text: "moon") { click_link "Edit" }

    expect(page).to have_field "Use a subdomain in the lvh.me domain to access this tenant",
                               type: :radio,
                               checked: true

    fill_in "Subdomain", with: "the-moon"
    click_button "Update tenant"

    expect(page).to have_content "Tenant updated successfully"

    click_link "the-moon.lvh.me"

    expect(current_host).to eq "http://the-moon.lvh.me"
    expect(page).to have_current_path root_path
    expect(page).to have_link "Sign in"
  end

  scenario "Hide and restore", :show_exceptions do
    create(:tenant, schema: "moon", name: "Moon")

    visit admin_tenants_path

    within("tr", text: "moon") do
      expect(page).to have_content "Yes"

      click_button "Enable tenant Moon"

      expect(page).to have_content "No"
      expect(page).not_to have_link "moon.lvh.me"
    end

    with_subdomain("moon") do
      visit root_path

      expect(page).to have_title "Not found"
    end

    visit admin_tenants_path

    within("tr", text: "moon") do
      expect(page).to have_content "No"

      click_button "Enable tenant Moon"

      expect(page).to have_content "Yes"
      expect(page).to have_link "moon.lvh.me"
    end

    with_subdomain("moon") do
      visit root_path

      expect(page).to have_link "Sign in"
      expect(page).not_to have_title "Not found"
    end
  end
end
