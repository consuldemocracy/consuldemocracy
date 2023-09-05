require "rails_helper"

describe "Organizations" do
  scenario "Shared links" do
    visit new_user_session_path

    expect(page).to have_link "Register a new account"
    expect(page).not_to have_link "Sign up as an organization"
  end
end
