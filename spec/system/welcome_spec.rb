require "rails_helper"

describe "Welcome screen" do
  it_behaves_like "remotely_translatable", :proposal, "root_path", {}
  it_behaves_like "remotely_translatable", :debate, "root_path", {}
  it_behaves_like "remotely_translatable", :legislation_process, "root_path", {}

  scenario "requires a logged in user" do
    visit welcome_path
    expect(page).to have_content "You must sign in or register to continue."
  end

  scenario "for a not verified user" do
    user = create(:user)
    login_through_form_as(user)

    expect(page).to have_current_path(page_path("welcome_not_verified"))
  end

  scenario "for a level two verified user" do
    user = create(:user, :level_two)
    login_as(user)

    visit welcome_path
    expect(page).to have_current_path(page_path("welcome_level_two_verified"))
  end

  scenario "for a level three verified user" do
    user = create(:user, :level_three)
    login_as(user)

    visit welcome_path
    expect(page).to have_current_path(page_path("welcome_level_three_verified"))
  end

  scenario "a regular user does not see it when coing to /email" do
    encrypted, plain = Devise.token_generator.generate(User, :email_verification_token)

    user = create(:user, email_verification_token: plain)

    visit email_path(email_verification_token: encrypted)

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password

    click_button "Enter"

    expect(page).to have_content("You are a verified user")

    expect(page).to have_current_path(account_path)
  end

  scenario "it is not shown more than once" do
    user = create(:user, sign_in_count: 2)

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario "is not shown to organizations" do
    organization = create(:organization)

    login_through_form_as(organization.user)

    expect(page).to have_current_path(root_path)
  end

  scenario "it is not shown to level-2 users" do
    user = create(:user, residence_verified_at: Time.current, confirmed_phone: "123")

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario "it is not shown to level-3 users" do
    user = create(:user, verified_at: Time.current)

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario "is not shown to administrators" do
    administrator = create(:administrator)

    login_through_form_as(administrator.user)

    expect(page).to have_current_path(root_path)
  end

  scenario "a regular users sees it the first time he logs in, with all options active
            if the setting skip_verification is activated" do
    Setting["feature.user.skip_verification"] = "true"

    user = create(:user)

    login_through_form_as(user)

    4.times do |i|
      expect(page).to have_css "li:nth-child(#{i + 1})"
    end
  end
end
