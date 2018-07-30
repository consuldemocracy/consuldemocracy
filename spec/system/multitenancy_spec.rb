require "rails_helper"

describe "Multitenancy" do
  before do
    create(:tenant, schema: "mars")
    create(:tenant, schema: "venus")
  end

  scenario "Disabled features", :no_js do
    Tenant.switch("mars") { Setting["process.debates"] = true }
    Tenant.switch("venus") { Setting["process.debates"] = nil }

    with_subdomain("mars") do
      visit debates_path

      expect(page).to have_css "#debates"
    end

    with_subdomain("venus") do
      expect { visit debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  scenario "Sign up into subdomain" do
    with_subdomain("mars") do
      visit "/"
      click_link "Register"

      fill_in "Username", with: "Marty McMartian"
      fill_in "Email", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      fill_in "Confirm password", with: "20151021"
      check "By registering you accept the terms and conditions of use"
      click_button "Register"

      confirm_email

      expect(page).to have_content "Your account has been confirmed."
    end
  end

  scenario "Users from another tenant can't sign in" do
    Tenant.switch("mars") { create(:user, email: "marty@consul.dev", password: "20151021") }

    with_subdomain("mars") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."
    end

    with_subdomain("venus") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      click_button "Enter"

      expect(page).to have_content "Invalid Email or username or password."
    end
  end
end
