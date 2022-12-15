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

    scenario "Copies the current user as the new tenant administrator" do
      user = create(:user, password: "secret_password", password_confirmation: "secret_password")
      create(:administrator, user: user)
      login_as(user)

      visit new_admin_tenant_path

      expect(page).to have_content "When you create a tenant, your current user"

      fill_in "Name", with: "Earthlings"
      fill_in "Subdomain", with: "earth"
      click_button "Create tenant"

      click_link "earth.lvh.me"

      click_link "Sign in"
      fill_in "Email or username", with: user.username
      fill_in "Password", with: "secret_password"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."
    end

    scenario "does not create admin by default on seeds when tenant is not default tenant" do
      allow(Rails.env).to receive(:test?).and_return(false)
      user = create(:user, password: "secret_password", password_confirmation: "secret_password")
      create(:administrator, user: user)
      login_as(user)

      visit new_admin_tenant_path

      fill_in "Name", with: "Earthlings"
      fill_in "Subdomain", with: "earth"
      click_button "Create tenant"

      click_link "earth.lvh.me"

      click_link "Sign in"
      fill_in "Email or username", with: "admin@consul.dev"
      fill_in "Password", with: "12345678"
      click_button "Enter"

      expect(page).to have_content "Invalid Email or username or password."
      expect(page).not_to have_content "You have been signed in successfully."
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
end
