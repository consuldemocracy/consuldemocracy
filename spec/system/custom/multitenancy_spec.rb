require "rails_helper"

describe "Multitenancy", :seed_tenants do
  before { create(:tenant, schema: "mars") }

  scenario "PostgreSQL extensions work for tenants" do
    Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_proposal_path
      fill_in "Proposal title", with: "Use the unaccent extension in Mars"
      fill_in "Proposal summary", with: "tsvector for María the Martian"

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
      fill_in "Debate title", with: "Found any water here?"
      fill_in_ckeditor "Initial debate text", with: "Found any water here?"

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
end
