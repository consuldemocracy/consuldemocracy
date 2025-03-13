require "rails_helper"

describe "Multitenancy", :seed_tenants do
  before { create(:tenant, schema: "mars") }

  scenario "Disabled features", :no_js do
    create(:tenant, schema: "venus")
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

  scenario "Content is different for differents tenants" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { create(:poll, name: "Human rights for Martians?") }

    with_subdomain("mars") do
      visit polls_path

      expect(page).to have_content "Human rights for Martians?"
      expect(page).to have_css "html.tenant-mars"
      expect(page).not_to have_css "html.tenant-venus"
    end

    with_subdomain("venus") do
      visit polls_path

      expect(page).to have_content "There are no open votings"
      expect(page).to have_css "html.tenant-venus"
      expect(page).not_to have_css "html.tenant-mars"
    end
  end

  scenario "PostgreSQL extensions work for tenants" do
    Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_proposal_path
      fill_in_new_proposal_title with: "Use the unaccent extension in Mars"
      fill_in "Proposal summary", with: "tsvector for María the Martian"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."

      click_link "No, I want to publish the proposal"

      expect(page).to have_content "You've created a proposal!"

      visit proposals_path
      click_button "Advanced search"
      fill_in "With the text", with: "Maria the Martian"
      click_button "Filter"

      expect(page).to have_content "Search results"
      expect(page).to have_content "María the Martian"
    end
  end

  scenario "Creating content in one tenant doesn't affect other tenants" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_debate_path
      fill_in_new_debate_title with: "Found any water here?"
      fill_in_ckeditor "Initial debate text", with: "Found any water here?"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Start a debate"

      expect(page).to have_content "Debate created successfully."
      expect(page).to have_content "Found any water here?"
    end

    with_subdomain("venus") do
      visit debates_path

      expect(page).to have_content "Sign in"
      expect(page).not_to have_css ".debate"

      visit new_debate_path

      expect(page).to have_content "You must sign in or register to continue."
    end
  end

  scenario "Users from another tenant cannot vote" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { create(:proposal, title: "Earth invasion") }
    Tenant.switch("venus") { login_as(create(:user)) }

    with_subdomain("venus") do
      visit proposals_path

      expect(page).to have_content "Sign out"
      expect(page).not_to have_content "Earth invasion"
    end

    with_subdomain("mars") do
      visit proposals_path

      within(".proposal", text: "Earth invasion") do
        click_button "Support"

        expect(page).to have_content "You must sign in or sign up to continue"
      end
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

      expect(page).to have_content "You have been sent a message containing a verification link"

      confirm_email

      expect(page).to have_content "Your account has been confirmed."
    end
  end

  scenario "Users from another tenant can't sign in" do
    create(:tenant, schema: "venus")
    Tenant.switch("mars") { create(:user, email: "marty@consul.dev", password: "20151021") }

    with_subdomain("mars") do
      login_through_form_with("marty@consul.dev", password: "20151021")

      expect(page).to have_content "You have been signed in successfully."
    end

    with_subdomain("venus") do
      login_through_form_with("marty@consul.dev", password: "20151021")

      expect(page).to have_content "Invalid Email or username or password."
    end
  end

  scenario "Uses the right tenant after failing to sign in" do
    with_subdomain("mars") do
      login_through_form_with("wrong@consul.dev", password: "wrong")

      expect(page).to have_content "Invalid Email or username or password"
      expect(page).to have_css "html.tenant-mars"
      expect(page).not_to have_css "html.tenant-public"
    end
  end

  scenario "Shows the not found page when accessing a non-existing tenant", :show_exceptions do
    with_subdomain("jupiter") do
      visit root_path

      expect(page).to have_title "Not found"
    end
  end
end
