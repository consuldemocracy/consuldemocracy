require "rails_helper"

describe "Sessions" do
  scenario "Staying in the same page after doing login/logout" do
    user = create(:user, sign_in_count: 10)
    debate = create(:debate)

    visit debate_path(debate)
    click_link "Sign in"
    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password
    click_button "Enter"

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

  scenario "Sign in redirects to the homepage if the user was there" do
    user = create(:user, :level_two)

    visit debates_path
    visit "/"
    click_link "Sign in"
    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password
    click_button "Enter"

    expect(page).to have_current_path "/"
  end

  scenario "Sign out does not redirect to POST requests URLs" do
    login_as(create(:user))

    visit account_path
    click_link "Verify my account"
    click_button "Verify residence"

    expect(page).to have_content(/errors prevented the verification of your residence/)

    click_link "Sign out"

    expect(page).to have_content "You must sign in or register to continue."
    expect(page).to have_current_path new_user_session_path
  end
end
