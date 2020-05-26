require "rails_helper"

describe "Sessions" do
  scenario "Staying in the same page after doing login/logout" do
    user = create(:user, sign_in_count: 10)
    debate = create(:debate)

    visit debate_path(debate)

    login_through_form_as(user)

    expect(page).to have_content("You have been signed in successfully")
    expect(page).to have_current_path(debate_path(debate))

    click_link "Sign out"

    expect(page).to have_content("You have been signed out successfully")
    expect(page).to have_current_path(debate_path(debate))
  end

  scenario "Sign in redirects keeping GET parameters" do
    create(:user, :level_two, email: "dev@consul.dev", password: "consuldev")
    heading = create(:budget_heading, name: "outskirts")

    visit budget_investments_path(heading.budget, heading_id: "outskirts")
    click_link "Sign in"
    fill_in "user_login",    with: "dev@consul.dev"
    fill_in "user_password", with: "consuldev"
    click_button "Enter"

    expect(page).to have_current_path budget_investments_path(heading.budget, heading_id: "outskirts")
  end
end
